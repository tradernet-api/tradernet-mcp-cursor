---
title: Tradernet MCP for Cursor
---

# Tradernet MCP for Cursor

**Trade-grade Tradernet API tools inside Cursor, over [Model Context Protocol](https://modelcontextprotocol.io/).**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](.cursor-plugin/plugin.json)
[![MCP](https://img.shields.io/badge/MCP-Streamable%20HTTP-2EC4B6.svg)](https://modelcontextprotocol.io/)
[![Platform](https://img.shields.io/badge/platform-Cursor-000000.svg)](https://cursor.com/)
[![GitHub stars](https://img.shields.io/github/stars/tradernet-api/tradernet-mcp?style=social)](https://github.com/tradernet-api/tradernet-mcp/stargazers)

[Tradernet API docs](https://tradernet.com/tradernet-api/mcp) ·
[Report issue](https://github.com/tradernet-api/tradernet-mcp/issues)

---

> **Warning:** Every call runs against a **real Tradernet account** — real data, orders and money. Use a dedicated test account, not your production one.

## Overview

This Cursor plugin connects the agent to the Tradernet API via Streamable HTTP (`https://tradernet.com/mcp/tn`). Once installed, you get ~**61 tools**: quotes, portfolio, orders, tariffs, reports and more.

Unlike a bare `mcp.json` snippet, the plugin bundles **rules**, a **SID-refresh skill**, **slash commands** and a **write/trade guard hook** so the agent handles auth, data quirks and risky operations safely.

## Features

| Capability | Description |
|------------|-------------|
| **MCP server** | Preconfigured `TN` endpoint with `${env:...}` header placeholders |
| **Rules** | Secret hygiene, HMAC vs SID auth, data format and write/trade caution |
| **Skill** | `tn-mcp-refresh-sid` — runbook for refreshing SID after `auth_by_login` |
| **Commands** | `/tn-connect` (smoke check), `/tn-refresh-sid` |
| **Guard hook** | `beforeMCPExecution` asks before orders, tariffs, lists, alerts and login |

## Table of contents

- [What's inside](#whats-inside)
- [Requirements](#requirements)
- [Secrets](#secrets-env-only-never-in-the-plugin)
- [Installation](#installation)
- [Quick start](#quick-start-after-install)
- [Security](#security)
- [Related integrations](#related-integrations)
- [License](#license)

## What's inside

| Component | File | Purpose |
|-----------|------|---------|
| MCP server | `mcp.json` | server `TN` → `https://tradernet.com/mcp/tn` (headers via `${env:...}`) |
| Rules | `rules/*.mdc` | secret hygiene, HMAC vs SID, data format and write/trade caution |
| Skill | `skills/tn-mcp-refresh-sid/` | runbook for refreshing the SID after `auth_by_login` |
| Commands | `commands/` | `/tn-connect` (smoke check), `/tn-refresh-sid` |
| Hook | `hooks/hooks.json` + `scripts/guard-write-tools.sh` | confirmation before write/trade tools |

## Requirements

1. A Tradernet account with API access.
2. An API key pair — [tradernet.com/tradernet-api/auth-api](https://tradernet.com/tradernet-api/auth-api)
   (`apiSecret` is shown only once).
3. [Cursor](https://cursor.com/) with Streamable HTTP MCP support.

## Secrets (env only, never in the plugin)

The plugin ships only `${env:...}` placeholders. You provide the keys yourself.

`~/.config/tn-mcp/credentials.env` (chmod 600):

```bash
export TN_API_KEY="your-apiKey"
export TN_API_SECRET="your-apiSecret"
export TN_LOGIN="user@example.com"     # optional, for auth_by_login
export TN_PASSWORD="your-password"     # optional
```

Source it from `~/.zshrc`:

```bash
[ -f ~/.config/tn-mcp/credentials.env ] && source ~/.config/tn-mcp/credentials.env
```

`TN_SID` (optional) lives in `.cursor/tn-session.env` and is refreshed by the
`tn-mcp-refresh-sid` skill. Cursor reads `${env:...}` at startup, so after
changing variables you need `source` + restart / Reload Window.

## Installation

### Local (testing and internal teams)

```bash
git clone https://github.com/tradernet-api/tradernet-mcp.git
ln -s "$(pwd)/tradernet-mcp" ~/.cursor/plugins/local/tradernet-mcp
chmod +x ~/.cursor/plugins/local/tradernet-mcp/scripts/guard-write-tools.sh
```

Then **Reload Window** (or restart Cursor). Check that the `TN` server appears under
**Settings → MCP**, and the `tn-mcp-*` rules under **Rules**.

### Marketplace

The plugin is distributed as a git repository and goes through Cursor's manual
review. Submit at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish).
The repository must be open source for the public Marketplace.

## Quick start after install

1. Set the secrets (see above) and restart Cursor from a terminal after `source`.
2. Run `/tn-connect` — a smoke check of the channel.
3. If you need a SID — run `/tn-refresh-sid`.

## Security

- Secrets never end up in the plugin, config or chat — env only.
- The `beforeMCPExecution` hook (`failClosed: true`) requires confirmation
  before `orders_put`, `orders_delete`, `orders_set_stop_loss`, `tariff_select`,
  list/alert changes and `auth_by_login`.
- Read-only tools (quotes, portfolio, reports) pass through without prompts.

## Related integrations

| Client | Repository | What you get |
|--------|------------|--------------|
| **Cursor** (this repo) | [tradernet-mcp](https://github.com/tradernet-api/tradernet-mcp) | Full plugin: rules, commands, hook, skill |
| **Claude Desktop** | [tradernet-mcp-claude](https://github.com/tradernet-api/tradernet-mcp-claude) | `mcp-remote` config + optional SID skill |
| **Codex** | [tradernet-mcp-codex](https://github.com/tradernet-api/tradernet-mcp-codex) | Codex plugin with MCP config and safety skill |

## License

[MIT](LICENSE) © Tradernet
