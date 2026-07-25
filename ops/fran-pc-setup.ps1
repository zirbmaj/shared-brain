#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Nowhere Labs mesh node setup for Fran's Windows 11 PC.
    Installs ollama (ROCm/AMD GPU), OpenSSH server, working directory, power settings.

.DESCRIPTION
    Hardware: Ryzen 9 7800X3D, 64GB DDR5, RX 7900 GRE (16GB VRAM, gfx1100)
    Tailscale IP: 100.89.96.110
    RAM allocation: 22GB for NWL services
    Availability: 24/7, heavy use 12am-6pm, light/on-demand 6pm-12am

    Run: powershell -ExecutionPolicy Bypass -File fran-pc-setup.ps1
    Uninstall: powershell -ExecutionPolicy Bypass -File fran-pc-setup.ps1 -Uninstall

.NOTES
    Author: Claude (Nowhere Labs engineering)
    Date: 2026-03-28
    Reversible: Yes (-Uninstall flag)
#>

param(
    [switch]$Uninstall,
    [string]$WorkDir = "C:\nwl\meridian",  # Meridian tenant under NWL root
    [switch]$AutoStart = $true           # Ollama auto-starts on boot
)

$ErrorActionPreference = "Stop"
$LogFile = "$env:TEMP\nwl-setup.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] [$Level] $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

function Test-Preflight {
    Write-Log "=== PREFLIGHT CHECKS ==="

    # Admin check
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "Must run as Administrator" "ERROR"
        exit 1
    }
    Write-Log "Admin privileges confirmed"

    # Windows version
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Log "OS: $($os.Caption) Build $($os.BuildNumber)"

    # GPU detection
    $gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -match "AMD|Radeon" }
    if ($gpu) {
        Write-Log "GPU detected: $($gpu.Name) ($([math]::Round($gpu.AdapterRAM / 1GB, 1)) GB)"
    } else {
        Write-Log "No AMD GPU detected -- ollama will run CPU-only" "WARN"
    }

    # RAM
    $totalRAM = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
    Write-Log "RAM: ${totalRAM} GB total, 22 GB allocated for NWL"

    # Disk space (need at least 20GB for ollama models)
    $drive = Get-PSDrive -Name ($WorkDir.Substring(0, 1))
    $freeGB = [math]::Round($drive.Free / 1GB, 1)
    if ($freeGB -lt 20) {
        Write-Log "Only ${freeGB} GB free on $($WorkDir.Substring(0, 2)) -- need at least 20 GB" "ERROR"
        exit 1
    }
    Write-Log "Disk: ${freeGB} GB free on $($WorkDir.Substring(0, 2))"

    Write-Log "Preflight passed"
}

function Install-Ollama {
    Write-Log "=== OLLAMA SETUP ==="

    # Check if already installed
    $ollamaPath = Get-Command ollama -ErrorAction SilentlyContinue
    if ($ollamaPath) {
        Write-Log "Ollama already installed at $($ollamaPath.Source)"
        $version = & ollama --version 2>&1
        Write-Log "Version: $version"
    } else {
        Write-Log "Installing ollama..."
        $installerUrl = "https://ollama.com/download/OllamaSetup.exe"
        $installerPath = "$env:TEMP\OllamaSetup.exe"
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
        Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
        Write-Log "Ollama installed"

        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    # Configure environment for AMD ROCm (gfx1100)
    # RX 7900 GRE is gfx1100 architecture -- ROCm support is native in ollama
    Write-Log "Configuring AMD GPU environment..."
    [System.Environment]::SetEnvironmentVariable("HSA_OVERRIDE_GFX_VERSION", "11.0.0", "Machine")
    [System.Environment]::SetEnvironmentVariable("OLLAMA_HOST", "0.0.0.0:11434", "Machine")

    # Resource limits: cap GPU memory so fran can game
    # Reserve 4GB VRAM for desktop/gaming, give ollama up to 12GB
    [System.Environment]::SetEnvironmentVariable("OLLAMA_GPU_MEMORY", "12GiB", "Machine")

    # RAM limit: 22GB allocated for NWL out of 64GB
    [System.Environment]::SetEnvironmentVariable("OLLAMA_MAX_LOADED_MODELS", "2", "Machine")
    [System.Environment]::SetEnvironmentVariable("OLLAMA_NUM_PARALLEL", "2", "Machine")

    # Models directory in our scoped workspace
    $modelsDir = "$WorkDir\ollama\models"
    if (-not (Test-Path $modelsDir)) { New-Item -Path $modelsDir -ItemType Directory -Force | Out-Null }
    [System.Environment]::SetEnvironmentVariable("OLLAMA_MODELS", $modelsDir, "Machine")
    Write-Log "Models directory: $modelsDir"

    # Auto-start configuration
    if ($AutoStart) {
        Write-Log "Configuring ollama auto-start via scheduled task..."
        $action = New-ScheduledTaskAction -Execute "ollama" -Argument "serve"
        $trigger = New-ScheduledTaskTrigger -AtStartup
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        Register-ScheduledTask -TaskName "NWL-Ollama" -Action $action -Trigger $trigger -Settings $settings -Description "Nowhere Labs ollama inference server" -Force | Out-Null
        Write-Log "Auto-start enabled"
    } else {
        Write-Log "Auto-start disabled -- use 'ollama serve' to start manually"
        # Create convenience start/stop scripts
        Set-Content -Path "$WorkDir\start-ollama.ps1" -Value @'
Write-Host "Starting ollama server..."
Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
Write-Host "Ollama running on 0.0.0.0:11434"
'@
        Set-Content -Path "$WorkDir\stop-ollama.ps1" -Value @'
Write-Host "Stopping ollama..."
Get-Process ollama -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "Ollama stopped"
'@
        Write-Log "Created start-ollama.ps1 and stop-ollama.ps1 in $WorkDir"
    }

    Write-Log "Ollama setup complete"
}

function Install-OpenSSH {
    Write-Log "=== OPENSSH SERVER SETUP ==="

    # Check if already installed
    $sshd = Get-WindowsCapability -Online | Where-Object { $_.Name -match "OpenSSH\.Server" }
    if ($sshd.State -eq "Installed") {
        Write-Log "OpenSSH Server already installed"
    } else {
        Write-Log "Installing OpenSSH Server..."
        Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
        Write-Log "OpenSSH Server installed"
    }

    # Configure sshd
    Start-Service sshd
    Set-Service -Name sshd -StartupType Automatic
    Write-Log "sshd service started and set to auto-start"

    # Key-based auth: Windows OpenSSH uses a different authorized_keys path for admin users
    # Admin accounts ignore ~/.ssh/authorized_keys and read from ProgramData instead
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($isAdmin) {
        $authKeysPath = "C:\ProgramData\ssh\administrators_authorized_keys"
        Write-Log "Admin account detected -- using $authKeysPath"
    } else {
        $sshDir = "$env:USERPROFILE\.ssh"
        if (-not (Test-Path $sshDir)) { New-Item -Path $sshDir -ItemType Directory -Force | Out-Null }
        $authKeysPath = "$sshDir\authorized_keys"
    }

    if (-not (Test-Path $authKeysPath)) {
        New-Item -Path $authKeysPath -ItemType File -Force | Out-Null
        # Admin authorized_keys needs strict ACL: only SYSTEM and Administrators
        if ($isAdmin) {
            $acl = Get-Acl $authKeysPath
            $acl.SetAccessRuleProtection($true, $false)
            $sysRule = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "Allow")
            $adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators", "FullControl", "Allow")
            $acl.AddAccessRule($sysRule)
            $acl.AddAccessRule($adminRule)
            Set-Acl -Path $authKeysPath -AclObject $acl
            Write-Log "Set strict ACL on administrators_authorized_keys (SYSTEM + Administrators only)"
        }
        Write-Log "Created $authKeysPath -- add NWL public keys here"
    } else {
        Write-Log "authorized_keys exists at $authKeysPath"
    }

    # Ensure key-based auth is enabled, password auth disabled
    $sshdConfig = "C:\ProgramData\ssh\sshd_config"
    if (Test-Path $sshdConfig) {
        $config = Get-Content $sshdConfig -Raw
        $modified = $false

        if ($config -notmatch "PubkeyAuthentication yes") {
            $config = $config -replace "#?PubkeyAuthentication.*", "PubkeyAuthentication yes"
            $modified = $true
        }
        if ($config -notmatch "PasswordAuthentication no") {
            $config = $config -replace "#?PasswordAuthentication.*", "PasswordAuthentication no"
            $modified = $true
        }

        if ($modified) {
            Set-Content -Path $sshdConfig -Value $config
            Restart-Service sshd
            Write-Log "sshd_config updated: pubkey auth enabled, password auth disabled"
        } else {
            Write-Log "sshd_config already configured correctly"
        }
    }

    # Firewall: allow SSH only from tailscale subnet
    $ruleName = "NWL-SSH-Tailscale"
    $existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    if (-not $existing) {
        New-NetFirewallRule -DisplayName $ruleName `
            -Direction Inbound -Protocol TCP -LocalPort 22 `
            -RemoteAddress "100.64.0.0/10" `
            -Action Allow -Profile Any `
            -Description "SSH access from Tailscale mesh only" | Out-Null
        Write-Log "Firewall rule added: SSH from tailscale only (100.64.0.0/10)"
    } else {
        Write-Log "Firewall rule '$ruleName' already exists"
    }

    # Firewall: allow ollama from tailscale
    $ollamaRule = "NWL-Ollama-Tailscale"
    $existing = Get-NetFirewallRule -DisplayName $ollamaRule -ErrorAction SilentlyContinue
    if (-not $existing) {
        New-NetFirewallRule -DisplayName $ollamaRule `
            -Direction Inbound -Protocol TCP -LocalPort 11434 `
            -RemoteAddress "100.64.0.0/10" `
            -Action Allow -Profile Any `
            -Description "Ollama API from Tailscale mesh only" | Out-Null
        Write-Log "Firewall rule added: ollama from tailscale only"
    } else {
        Write-Log "Firewall rule '$ollamaRule' already exists"
    }

    Write-Log "OpenSSH setup complete"
}

function Set-WorkDirectory {
    Write-Log "=== WORKING DIRECTORY ==="

    $dirs = @(
        $WorkDir,
        "$WorkDir\ollama",
        "$WorkDir\ollama\models",
        "$WorkDir\logs",
        "$WorkDir\data"
    )

    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
            Write-Log "Created $dir"
        } else {
            Write-Log "Exists: $dir"
        }
    }

    # Create status file for health checks
    $status = @{
        node = "fran-pc"
        tailscale_ip = "100.89.96.110"
        setup_date = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        services = @("ollama")
        work_dir = $WorkDir
        gpu = "RX 7900 GRE 16GB (gfx1100)"
        ram_allocated = "22GB"
    } | ConvertTo-Json -Depth 3
    Set-Content -Path "$WorkDir\node-status.json" -Value $status
    Write-Log "Node status written to $WorkDir\node-status.json"
}

function Set-PowerSettings {
    Write-Log "=== POWER SETTINGS ==="

    # Save current power scheme for uninstall
    $currentScheme = powercfg /getactivescheme
    Set-Content -Path "$WorkDir\.power-backup.txt" -Value $currentScheme
    Write-Log "Saved current power scheme for rollback"

    # Disable sleep and hibernate
    powercfg /change standby-timeout-ac 0
    powercfg /change hibernate-timeout-ac 0
    powercfg /hibernate off
    Write-Log "Sleep disabled, hibernate disabled"

    # Keep display sleep (fran's preference -- saves power without stopping services)
    powercfg /change monitor-timeout-ac 15
    Write-Log "Display sleep: 15 min (services unaffected)"
}

function Invoke-Uninstall {
    Write-Log "=== UNINSTALLING NWL MESH NODE ==="

    # Remove scheduled task
    Unregister-ScheduledTask -TaskName "NWL-Ollama" -Confirm:$false -ErrorAction SilentlyContinue
    Write-Log "Removed ollama scheduled task"

    # Remove firewall rules
    Remove-NetFirewallRule -DisplayName "NWL-SSH-Tailscale" -ErrorAction SilentlyContinue
    Remove-NetFirewallRule -DisplayName "NWL-Ollama-Tailscale" -ErrorAction SilentlyContinue
    Write-Log "Removed firewall rules"

    # Remove environment variables
    foreach ($var in @("HSA_OVERRIDE_GFX_VERSION", "OLLAMA_HOST", "OLLAMA_GPU_MEMORY", "OLLAMA_MAX_LOADED_MODELS", "OLLAMA_NUM_PARALLEL", "OLLAMA_MODELS")) {
        [System.Environment]::SetEnvironmentVariable($var, $null, "Machine")
    }
    Write-Log "Removed environment variables"

    # Restore power settings
    $backupFile = "$WorkDir\.power-backup.txt"
    if (Test-Path $backupFile) {
        powercfg /change standby-timeout-ac 30
        powercfg /change hibernate-timeout-ac 180
        Write-Log "Power settings restored to defaults"
    }

    # Stop ollama
    Get-Process ollama -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Log "Ollama stopped"

    # Note: we don't uninstall ollama or remove $WorkDir -- fran might want to keep them
    Write-Log "Uninstall complete. Ollama binary and $WorkDir left in place."
    Write-Log "To fully remove: uninstall ollama from Add/Remove Programs, then delete $WorkDir"
}

# === MAIN ===

$mode = if ($Uninstall) { 'UNINSTALL' } else { 'INSTALL' }
Write-Log "Nowhere Labs mesh node setup -- $mode"

if ($Uninstall) {
    Invoke-Uninstall
    exit 0
}

Test-Preflight
Set-WorkDirectory
Install-Ollama
Install-OpenSSH
Set-PowerSettings

Write-Log ""
Write-Log "=== SETUP COMPLETE ==="
Write-Log "Node: fran-pc (100.89.96.110)"
Write-Log "Working directory: $WorkDir"
Write-Log 'Ollama: 0.0.0.0:11434 (12GB VRAM cap, 2 models max)'
Write-Log 'SSH: port 22, key-auth only, tailscale subnet'
Write-Log ""
Write-Log "NEXT STEPS:"
$authKeysDisplay = if ($isAdmin) { 'C:\ProgramData\ssh\administrators_authorized_keys' } else { "$env:USERPROFILE\.ssh\authorized_keys" }
Write-Log "  1. Add NWL public keys to: $authKeysDisplay"
$startDisplay = if ($AutoStart) { 'auto-starts on boot' } else { "$WorkDir\start-ollama.ps1" }
Write-Log "  2. Start ollama: $startDisplay"
Write-Log '  3. Pull models: ollama pull llama3.2 (or whatever the team needs)'
Write-Log '  4. Test from mini: curl http://100.89.96.110:11434/api/tags'
Write-Log ""
Write-Log "Full log: $LogFile"
