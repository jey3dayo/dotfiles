---
name: mcp-tools
description: |
  [What] MCP (Model Context Protocol) server setup and security guide. Provides configuration file locations, major server installation, environment variable management, troubleshooting, and security best practices. Activates when configuring MCP servers, integrating external tools, or addressing security concerns.
  [When] Use when: setting up MCP servers for the first time, adding new MCP servers, locating configuration files, managing environment variables and tokens securely, troubleshooting MCP server startup issues, or reviewing security best practices.
  [Keywords] mcp tools, MCP, Model, Context, Protocol
---

# MCP Tools

MCP (Model Context Protocol) server setup and security guide. Enables secure integration with external tools.

## Overview

MCP (Model Context Protocol) is the protocol Claude Code uses to integrate with external tools and services. This skill provides guidance on configuring MCP servers, using major servers, and securely managing sensitive information.

## When to Use

This skill is activated in the following cases:

- Setting up an MCP server for the first time
- Adding a new MCP server
- Not sure where the configuration file is located
- Wanting to know how to securely manage environment variables and tokens
- MCP server won't start (troubleshooting)
- Reviewing security best practices

## Trigger Keywords

### Japanese

- "MCP", "MCPサーバー", "MCP設定"
- "claude_desktop_config.json", "設定ファイル"
- "外部ツール統合", "GitHub統合", "データベース統合"
- "環境変数", "APIキー", "トークン管理"

### English

- "MCP", "MCP server", "MCP setup", "MCP configuration"
- "claude_desktop_config.json", "config file"
- "external tool integration", "GitHub integration"
- "environment variables", "API key", "token management"

## Quick Start

### Configuration File Locations

```bash
# macOS
~/Library/Application Support/Claude/claude_desktop_config.json

# Windows
%APPDATA%\Claude\claude_desktop_config.json

# Linux
~/.config/Claude/claude_desktop_config.json
```

### Basic Setup Steps

```bash
# 1. Quit Claude Desktop
osascript -e 'quit app "Claude"'

# 2. Edit the configuration file
code ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 3. Add MCP server (see below)

# 4. Restart Claude Desktop
open -a Claude

# 5. Verify in Settings → Developer → MCP Servers
```

## Detailed Reference

- For major servers, security, integration examples, troubleshooting, and usage examples, see `references/mcp-tools-details.md`

## Next Steps

1. Run through the quick start
2. Select and install the necessary servers
3. Review security settings

## Related Resources

- `references/mcp-tools-details.md`
