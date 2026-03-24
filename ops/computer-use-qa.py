#!/usr/bin/env python3
"""
Nowhere Labs — Computer Use Visual QA
Runs Claude computer use against live products to perform visual/UX audits.

Usage:
    python3 computer-use-qa.py                    # audit all products
    python3 computer-use-qa.py drift              # audit one product
    python3 computer-use-qa.py drift static-fm    # audit specific products
    python3 computer-use-qa.py --mobile drift     # mobile viewport audit
    python3 computer-use-qa.py --report-only      # regenerate report from last run

Requires:
    - ANTHROPIC_API_KEY env var
    - Docker running with computer use container
    - pip install anthropic

The script manages the docker container lifecycle automatically.
"""

import anthropic
import base64
import json
import os
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

# --- Configuration ---

CONTAINER_NAME = "nwl-visual-qa"
CONTAINER_IMAGE = "ghcr.io/anthropics/anthropic-quickstarts:computer-use-demo-latest"
DISPLAY_WIDTH = 1024
DISPLAY_HEIGHT = 768
MODEL = "claude-opus-4-6-20250219"
BETA_FLAG = "computer-use-2025-11-24"
TOOL_VERSION = "computer_20251124"
MAX_ITERATIONS = 25  # safety limit per product audit
MAX_TOKENS = 4096

REPORTS_DIR = Path.home() / "shared-brain" / "ops" / "qa-reports"
SCREENSHOTS_DIR = REPORTS_DIR / "screenshots"

# Product registry — URLs and what to check
PRODUCTS = {
    "drift": {
        "url": "https://drift.nowherelabs.dev/app.html",
        "name": "Drift",
        "checks": [
            "Layer controls are visible and labeled",
            "Master volume slider is present and functional",
            "Reset button is visible",
            "Publish button is visible",
            "Navigation links work (discover, home)",
            "Color scheme has sufficient contrast",
            "Mobile: controls don't overflow viewport",
        ],
    },
    "discover": {
        "url": "https://drift.nowherelabs.dev/discover.html",
        "name": "Drift Discover",
        "checks": [
            "Mix grid displays published mixes",
            "Play counts are visible",
            "Mix cards are clickable",
            "Layout is responsive",
        ],
    },
    "static-fm": {
        "url": "https://static-fm.nowherelabs.dev/",
        "name": "Static FM",
        "checks": [
            "Player controls are visible",
            "Track info displays correctly",
            "Floating chat widget is present",
            "Footer is visible and not cut off",
            "Volume controls work",
        ],
    },
    "dashboard": {
        "url": "https://nowherelabs.dev/dashboard/",
        "name": "Dashboard",
        "checks": [
            "Session picker is present",
            "Analytics data loads",
            "Navigation to other products works",
            "Layout is clean and readable",
        ],
    },
    "letters": {
        "url": "https://letters.nowherelabs.dev/",
        "name": "Letters to Nowhere",
        "checks": [
            "Letter input area is visible",
            "Submit/send mechanism works",
            "Visual atmosphere matches brand",
            "OG image meta tag present",
        ],
    },
    "pulse": {
        "url": "https://pulse.nowherelabs.dev/",
        "name": "Pulse",
        "checks": [
            "Timer display is visible",
            "Start/stop controls work",
            "Visual design is clean",
            "OG image meta tag present",
        ],
    },
    "heartbeat": {
        "url": "https://nowherelabs.dev/heartbeat",
        "name": "Heartbeat",
        "checks": [
            "Vital signs display loads",
            "Event counts are populated",
            "Real-time updates appear",
        ],
    },
    "chat": {
        "url": "https://nowherelabs.dev/chat",
        "name": "Talk to Nowhere",
        "checks": [
            "Chat input is visible",
            "Presence indicator shows",
            "Message area renders correctly",
        ],
    },
    "homepage": {
        "url": "https://nowherelabs.dev/",
        "name": "Nowhere Labs Homepage",
        "checks": [
            "All product links are visible and work",
            "Navigation is clear",
            "Brand aesthetic is consistent",
            "Dashboard link is prominent",
        ],
    },
}


# --- Docker Management ---


def is_container_running():
    """Check if the QA container is already running."""
    result = subprocess.run(
        ["docker", "inspect", "-f", "{{.State.Running}}", CONTAINER_NAME],
        capture_output=True,
        text=True,
    )
    return result.returncode == 0 and "true" in result.stdout


def start_container(mobile=False):
    """Start the computer use docker container."""
    width = 375 if mobile else DISPLAY_WIDTH
    height = 812 if mobile else DISPLAY_HEIGHT

    if is_container_running():
        print(f"  Container '{CONTAINER_NAME}' already running")
        return True

    # Remove stopped container if exists
    subprocess.run(
        ["docker", "rm", "-f", CONTAINER_NAME],
        capture_output=True,
    )

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("ERROR: ANTHROPIC_API_KEY not set")
        return False

    print(f"  Starting container (viewport: {width}x{height})...")
    result = subprocess.run(
        [
            "docker",
            "run",
            "-d",
            "--name",
            CONTAINER_NAME,
            "-e",
            f"ANTHROPIC_API_KEY={api_key}",
            "-e",
            f"WIDTH={width}",
            "-e",
            f"HEIGHT={height}",
            "-p",
            "5900:5900",
            "-p",
            "6080:6080",
            "-p",
            "8080:8080",
            CONTAINER_IMAGE,
        ],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(f"ERROR: Failed to start container: {result.stderr}")
        return False

    # Wait for container to be ready
    print("  Waiting for desktop environment to initialize...")
    time.sleep(10)
    return True


def stop_container():
    """Stop and remove the QA container."""
    subprocess.run(["docker", "rm", "-f", CONTAINER_NAME], capture_output=True)


def exec_in_container(command):
    """Execute a command inside the container and return output."""
    result = subprocess.run(
        ["docker", "exec", CONTAINER_NAME, "bash", "-c", command],
        capture_output=True,
        text=True,
        timeout=30,
    )
    return result.stdout, result.stderr, result.returncode


def take_screenshot_in_container():
    """Take a screenshot inside the container and return base64 PNG."""
    timestamp = int(time.time() * 1000)
    remote_path = f"/tmp/screenshot_{timestamp}.png"

    # Use xdotool/scrot inside the container
    exec_in_container(
        f"DISPLAY=:1 scrot -o {remote_path} 2>/dev/null || "
        f"DISPLAY=:1 import -window root {remote_path}"
    )

    # Read the file back as base64
    stdout, _, rc = exec_in_container(f"base64 -w0 {remote_path}")
    if rc != 0 or not stdout.strip():
        return None

    # Cleanup
    exec_in_container(f"rm -f {remote_path}")
    return stdout.strip()


def execute_computer_action(action_input):
    """Execute a computer use action in the container and return screenshot."""
    action = action_input.get("action")

    if action == "screenshot":
        pass  # Just take screenshot below

    elif action == "left_click":
        x, y = action_input["coordinate"]
        exec_in_container(f"DISPLAY=:1 xdotool mousemove {x} {y} click 1")

    elif action == "double_click":
        x, y = action_input["coordinate"]
        exec_in_container(
            f"DISPLAY=:1 xdotool mousemove {x} {y} click --repeat 2 1"
        )

    elif action == "right_click":
        x, y = action_input["coordinate"]
        exec_in_container(f"DISPLAY=:1 xdotool mousemove {x} {y} click 3")

    elif action == "type":
        text = action_input["text"]
        # Escape special characters for xdotool
        exec_in_container(f"DISPLAY=:1 xdotool type --clearmodifiers '{text}'")

    elif action == "key":
        key = action_input["text"]
        # Map common key names
        key_map = {
            "Return": "Return",
            "Tab": "Tab",
            "Escape": "Escape",
            "BackSpace": "BackSpace",
            "ctrl+l": "ctrl+l",
            "ctrl+a": "ctrl+a",
            "ctrl+c": "ctrl+c",
            "ctrl+v": "ctrl+v",
        }
        mapped = key_map.get(key, key)
        exec_in_container(f"DISPLAY=:1 xdotool key {mapped}")

    elif action == "scroll":
        x, y = action_input["coordinate"]
        direction = action_input.get("scroll_direction", "down")
        amount = action_input.get("scroll_amount", 3)
        button = 5 if direction == "down" else 4
        exec_in_container(
            f"DISPLAY=:1 xdotool mousemove {x} {y} click --repeat {amount} {button}"
        )

    elif action == "mouse_move":
        x, y = action_input["coordinate"]
        exec_in_container(f"DISPLAY=:1 xdotool mousemove {x} {y}")

    elif action == "zoom":
        # Zoom is handled by the API — take screenshot and crop
        pass

    elif action == "wait":
        time.sleep(action_input.get("duration", 1))

    else:
        print(f"  Unknown action: {action}")

    # Small delay for UI to settle
    time.sleep(0.5)

    # Always return a screenshot after the action
    return take_screenshot_in_container()


# --- Agent Loop ---


def build_system_prompt(product, checks, mobile=False):
    """Build the system prompt for visual QA."""
    viewport = "mobile (375x812)" if mobile else "desktop (1024x768)"
    checks_list = "\n".join(f"  - {c}" for c in checks)

    return f"""You are a visual QA auditor for Nowhere Labs. Your job is to evaluate the UI/UX of our live products by navigating them in a real browser.

Product: {product['name']}
URL: {product['url']}
Viewport: {viewport}

## Checklist
{checks_list}

## Instructions
1. Open Firefox and navigate to the product URL
2. Take a screenshot and evaluate the initial load state
3. Work through each checklist item — interact with the UI to verify functionality
4. Check for visual issues: contrast, alignment, overflow, truncation, broken images
5. Test interactive elements: buttons, sliders, links
6. If mobile viewport: check that nothing overflows horizontally, touch targets are adequate

## Output Format
When you've completed your audit, provide a structured report:

### [Product Name] — Visual QA Report
**Viewport:** desktop/mobile
**Date:** {datetime.now().strftime('%Y-%m-%d %H:%M CST')}

**Pass/Fail Summary:** X/Y checks passed

**Findings:**
For each check item, report:
- PASS / FAIL / WARN
- What you observed
- Screenshot reference if relevant

**Issues Found:**
- Severity (critical/major/minor/cosmetic)
- Description
- Steps to reproduce
- Suggested fix

**Overall Assessment:** one paragraph summary

After each action, take a screenshot to verify the result before proceeding."""


def run_audit(product_key, mobile=False):
    """Run a visual QA audit on a single product."""
    product = PRODUCTS[product_key]
    checks = product["checks"]

    print(f"\n{'='*60}")
    print(f"  Auditing: {product['name']}")
    print(f"  URL: {product['url']}")
    print(f"  Viewport: {'mobile' if mobile else 'desktop'}")
    print(f"{'='*60}")

    client = anthropic.Anthropic()

    system_prompt = build_system_prompt(product, checks, mobile)

    tools = [
        {
            "type": TOOL_VERSION,
            "name": "computer",
            "display_width_px": 375 if mobile else DISPLAY_WIDTH,
            "display_height_px": 812 if mobile else DISPLAY_HEIGHT,
            "enable_zoom": True,
        },
    ]

    # Initial message: tell Claude to start the audit
    messages = [
        {
            "role": "user",
            "content": f"Begin the visual QA audit of {product['name']} at {product['url']}. "
            f"Open Firefox, navigate to the URL, and work through the checklist. "
            f"Start by taking a screenshot to see the current state of the desktop.",
        }
    ]

    screenshots_saved = []
    iteration = 0
    final_report = None

    while iteration < MAX_ITERATIONS:
        iteration += 1
        print(f"  Step {iteration}/{MAX_ITERATIONS}...", end=" ", flush=True)

        try:
            response = client.beta.messages.create(
                model=MODEL,
                max_tokens=MAX_TOKENS,
                system=system_prompt,
                messages=messages,
                tools=tools,
                betas=[BETA_FLAG],
            )
        except anthropic.APIError as e:
            print(f"\n  API error: {e}")
            break

        # Process response
        assistant_content = response.content
        messages.append({"role": "assistant", "content": assistant_content})

        # Check for tool use
        tool_results = []
        has_text = False

        for block in assistant_content:
            if block.type == "text":
                has_text = True
                final_report = block.text
                print("report generated")

            elif block.type == "tool_use":
                action_desc = block.input.get("action", "unknown")
                print(f"{action_desc}", end=" ", flush=True)

                # Execute the action
                screenshot_b64 = execute_computer_action(block.input)

                if screenshot_b64:
                    # Save screenshot
                    ss_path = save_screenshot(
                        screenshot_b64, product_key, iteration, action_desc, mobile
                    )
                    if ss_path:
                        screenshots_saved.append(ss_path)

                    tool_results.append(
                        {
                            "type": "tool_result",
                            "tool_use_id": block.id,
                            "content": [
                                {
                                    "type": "image",
                                    "source": {
                                        "type": "base64",
                                        "media_type": "image/png",
                                        "data": screenshot_b64,
                                    },
                                }
                            ],
                        }
                    )
                else:
                    tool_results.append(
                        {
                            "type": "tool_result",
                            "tool_use_id": block.id,
                            "content": "Screenshot capture failed",
                            "is_error": True,
                        }
                    )

        print()  # newline after step

        # If no tool calls, we're done
        if not tool_results:
            break

        # Send results back
        messages.append({"role": "user", "content": tool_results})

    return {
        "product": product_key,
        "name": product["name"],
        "url": product["url"],
        "mobile": mobile,
        "iterations": iteration,
        "screenshots": screenshots_saved,
        "report": final_report,
        "timestamp": datetime.now().isoformat(),
    }


# --- Output & Reporting ---


def save_screenshot(b64_data, product_key, step, action, mobile=False):
    """Save a screenshot to disk."""
    SCREENSHOTS_DIR.mkdir(parents=True, exist_ok=True)

    viewport = "mobile" if mobile else "desktop"
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    filename = f"{product_key}_{viewport}_step{step:02d}_{action}_{timestamp}.png"
    filepath = SCREENSHOTS_DIR / filename

    try:
        with open(filepath, "wb") as f:
            f.write(base64.b64decode(b64_data))
        return str(filepath)
    except Exception as e:
        print(f"  Warning: failed to save screenshot: {e}")
        return None


def generate_report(results):
    """Generate a combined markdown report from all audit results."""
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    report_path = REPORTS_DIR / f"visual-qa-{timestamp}.md"

    lines = [
        "# Nowhere Labs — Visual QA Report",
        f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M CST')}",
        f"**Products audited:** {len(results)}",
        f"**Model:** {MODEL}",
        "",
        "---",
        "",
    ]

    for result in results:
        lines.append(f"## {result['name']}")
        lines.append(f"**URL:** {result['url']}")
        lines.append(
            f"**Viewport:** {'mobile' if result['mobile'] else 'desktop'}"
        )
        lines.append(f"**Steps:** {result['iterations']}")
        lines.append(f"**Screenshots:** {len(result['screenshots'])}")
        lines.append("")

        if result["report"]:
            lines.append(result["report"])
        else:
            lines.append("*No report generated — audit may have hit iteration limit*")

        lines.append("")
        lines.append("---")
        lines.append("")

    report_content = "\n".join(lines)

    with open(report_path, "w") as f:
        f.write(report_content)

    print(f"\n  Report saved: {report_path}")
    return report_path


# --- Main ---


def main():
    args = sys.argv[1:]
    mobile = "--mobile" in args
    report_only = "--report-only" in args

    if "--mobile" in args:
        args.remove("--mobile")
    if "--report-only" in args:
        args.remove("--report-only")

    # Determine which products to audit
    if args:
        products_to_audit = [p for p in args if p in PRODUCTS]
        invalid = [p for p in args if p not in PRODUCTS]
        if invalid:
            print(f"Unknown products: {', '.join(invalid)}")
            print(f"Available: {', '.join(PRODUCTS.keys())}")
            sys.exit(1)
    else:
        products_to_audit = list(PRODUCTS.keys())

    if report_only:
        # Find latest results and regenerate
        print("--report-only not yet implemented (need results cache)")
        sys.exit(1)

    # Preflight checks
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("ERROR: ANTHROPIC_API_KEY not set")
        print("  export ANTHROPIC_API_KEY='your-key'")
        sys.exit(1)

    # Check docker
    docker_check = subprocess.run(
        ["docker", "info"], capture_output=True, text=True
    )
    if docker_check.returncode != 0:
        print("ERROR: Docker is not running")
        print("  open -a Docker")
        sys.exit(1)

    print(f"Nowhere Labs Visual QA")
    print(f"  Products: {', '.join(products_to_audit)}")
    print(f"  Viewport: {'mobile' if mobile else 'desktop'}")
    print(f"  Model: {MODEL}")
    print()

    # Start container
    if not start_container(mobile):
        sys.exit(1)

    # Run audits
    results = []
    try:
        for product_key in products_to_audit:
            result = run_audit(product_key, mobile)
            results.append(result)
    except KeyboardInterrupt:
        print("\n\nAudit interrupted. Generating partial report...")
    finally:
        # Generate report from whatever we have
        if results:
            report_path = generate_report(results)
            print(f"\n  Screenshots: {SCREENSHOTS_DIR}/")
            print(f"  Report: {report_path}")

        # Stop container
        print("\n  Stopping container...")
        stop_container()

    print("\nDone.")


if __name__ == "__main__":
    main()
