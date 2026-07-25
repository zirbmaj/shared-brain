#!/usr/bin/env bun
import { appendFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { spawn } from 'node:child_process';
import { Client, GatewayIntentBits, Partials } from '/Users/jambrizr/.claude/plugins/cache/claude-plugins-official/discord/0.0.4/node_modules/discord.js';

const stateDir = process.env.DISCORD_STATE_DIR ?? '/Users/jambrizr/.claude/channels/discord-relay';
const workspace = process.env.CODEX_RELAY_WORKSPACE ?? '/Users/jambrizr/teams/nwl/relay-workspace';
const logPath = process.env.CODEX_DISCORD_BRIDGE_LOG ?? '/Users/jambrizr/shared-brain/ops/codex-discord-relay-bridge.jsonl';
const lockPath = process.env.CODEX_DISCORD_BRIDGE_LOCK ?? '/tmp/codex-discord-relay-bridge.lock';
const maxReplyChars = Number(process.env.CODEX_DISCORD_BRIDGE_MAX_REPLY_CHARS ?? '1800');

function loadDotEnv(path) {
  if (!existsSync(path)) return;
  for (const raw of readFileSync(path, 'utf8').split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const idx = line.indexOf('=');
    if (idx < 1) continue;
    const key = line.slice(0, idx).trim();
    const val = line.slice(idx + 1).trim().replace(/^['"]|['"]$/g, '');
    if (!process.env[key]) process.env[key] = val;
  }
}

function log(event) {
  appendFileSync(logPath, `${JSON.stringify({ ts: new Date().toISOString(), ...event })}\n`);
}

function loadAccess() {
  const accessPath = join(stateDir, 'access.json');
  const raw = existsSync(accessPath) ? readFileSync(accessPath, 'utf8') : '{}';
  const access = JSON.parse(raw);
  return {
    allowFrom: new Set((access.allowFrom ?? []).map(String)),
    groups: access.groups ?? {},
  };
}

function splitMessage(text) {
  const chunks = [];
  let rest = text.trim() || '(empty response)';
  while (rest.length > maxReplyChars) {
    chunks.push(rest.slice(0, maxReplyChars));
    rest = rest.slice(maxReplyChars);
  }
  chunks.push(rest);
  return chunks;
}

function runCodexPrompt(prompt) {
  return new Promise((resolve, reject) => {
    const outPath = `/tmp/codex-discord-relay-${Date.now()}-${Math.random().toString(36).slice(2)}.txt`;
    const args = [
      'exec',
      '--ephemeral',
      '--dangerously-bypass-approvals-and-sandbox',
      '-C',
      workspace,
      '-c',
      'mcp_servers.discord.enabled=false',
      '--color',
      'never',
      '-o',
      outPath,
      '-',
    ];
    const child = spawn('codex', args, {
      cwd: workspace,
      env: {
        ...process.env,
        AGENT_NAME: 'relay',
        NWL_AGENT_NAME: 'relay',
        DISCORD_STATE_DIR: stateDir,
      },
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    let stdout = '';
    let stderr = '';
    const timeout = setTimeout(() => {
      child.kill('SIGTERM');
      reject(new Error('codex exec timed out after 180s'));
    }, 180000);

    child.stdout.on('data', d => { stdout += d.toString(); });
    child.stderr.on('data', d => { stderr += d.toString(); });
    child.on('error', err => {
      clearTimeout(timeout);
      reject(err);
    });
    child.on('exit', code => {
      clearTimeout(timeout);
      if (code !== 0) {
        reject(new Error(`codex exec exited ${code}: ${stderr || stdout}`));
        return;
      }
      const response = existsSync(outPath) ? readFileSync(outPath, 'utf8') : stdout;
      resolve(response.trim());
    });
    child.stdin.end(prompt);
  });
}

async function main() {
  loadDotEnv(join(stateDir, '.env'));
  if (!process.env.DISCORD_BOT_TOKEN) throw new Error(`missing DISCORD_BOT_TOKEN in ${stateDir}/.env`);
  mkdirSync(dirname(logPath), { recursive: true });
  writeFileSync(lockPath, String(process.pid));

  const client = new Client({
    intents: [
      GatewayIntentBits.DirectMessages,
      GatewayIntentBits.Guilds,
      GatewayIntentBits.GuildMessages,
      GatewayIntentBits.MessageContent,
    ],
    partials: [Partials.Channel],
  });

  let busy = false;
  client.once('clientReady', c => {
    log({ event: 'ready', user: c.user.tag, user_id: c.user.id, stateDir, workspace });
  });

  client.on('messageCreate', async msg => {
    if (msg.author.id === client.user?.id) return;
    const access = loadAccess();
    const isDm = msg.channel?.isDMBased?.() ?? false;
    const group = access.groups[msg.channelId];
    const allowed = isDm ? access.allowFrom.has(msg.author.id) : Boolean(group);
    if (!allowed) {
      log({ event: 'drop', reason: 'not_allowed', author_id: msg.author.id, channel_id: msg.channelId, message_id: msg.id });
      return;
    }
    if (group?.requireMention && !msg.mentions.users.has(client.user.id)) {
      log({ event: 'drop', reason: 'mention_required', author_id: msg.author.id, channel_id: msg.channelId, message_id: msg.id });
      return;
    }

    const inbound = {
      event: 'inbound',
      author: `${msg.author.username}#${msg.author.discriminator}`,
      author_id: msg.author.id,
      channel_id: msg.channelId,
      message_id: msg.id,
      is_dm: isDm,
      content: msg.content,
    };
    log(inbound);

    if (busy) {
      await msg.reply('relay/codex received this, but one Discord task is already running. I queued no work for this message.').catch(() => {});
      log({ event: 'busy_reply', message_id: msg.id });
      return;
    }

    busy = true;
    try {
      if ('sendTyping' in msg.channel) await msg.channel.sendTyping().catch(() => {});
      const prompt = [
        'You are Relay, the NWL ops lane running under Codex.',
        'Respond to this Discord message from jam concisely and operationally.',
        'Do not claim you used Discord tools. Do not include markdown tables unless the message asks for status.',
        'Your final answer will be sent back to Discord by the bridge.',
        '',
        `Discord author: ${inbound.author} (${inbound.author_id})`,
        `Discord channel_id: ${inbound.channel_id}`,
        `Discord message_id: ${inbound.message_id}`,
        '',
        'Message:',
        msg.content || '(empty message)',
      ].join('\n');
      const response = await runCodexPrompt(prompt);
      const sent = [];
      for (const chunk of splitMessage(response)) {
        const reply = await msg.reply(chunk);
        sent.push(reply.id);
      }
      log({ event: 'reply_sent', inbound_message_id: msg.id, reply_message_ids: sent });
    } catch (err) {
      const errorText = err instanceof Error ? err.message : String(err);
      log({ event: 'error', inbound_message_id: msg.id, error: errorText });
      await msg.reply(`relay/codex receive path is live, but response generation failed: ${errorText.slice(0, 1200)}`).catch(() => {});
    } finally {
      busy = false;
    }
  });

  process.on('SIGTERM', async () => {
    log({ event: 'shutdown', signal: 'SIGTERM' });
    await client.destroy();
    process.exit(0);
  });

  await client.login(process.env.DISCORD_BOT_TOKEN);
}

main().catch(err => {
  log({ event: 'fatal', error: err instanceof Error ? err.message : String(err) });
  process.exit(1);
});
