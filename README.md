# Homebrew Tap for odoo-rust-mcp

This is the official Homebrew tap for [odoo-rust-mcp](https://github.com/rachmataditiya/odoo-rust-mcp) - a Model Context Protocol (MCP) server for Odoo integration.

## Quick Start

```bash
# Install
brew tap rachmataditiya/odoo-rust-mcp
brew install rust-mcp

# Configure (edit with your Odoo credentials)
nano ~/.config/odoo-rust-mcp/env

# Start as background service
brew services start rust-mcp
```

## Installation

```bash
# Add this tap
brew tap rachmataditiya/odoo-rust-mcp

# Install rust-mcp
brew install rust-mcp
```

Or install directly in one command:

```bash
brew install rachmataditiya/odoo-rust-mcp/rust-mcp
```

## What Gets Installed

After installation, you'll have:

| Component | Location |
|-----------|----------|
| Binary | `/opt/homebrew/bin/rust-mcp` |
| Service wrapper | `/opt/homebrew/bin/rust-mcp-service` |
| Default configs | `/opt/homebrew/share/odoo-rust-mcp/` |
| User configs | `~/.config/odoo-rust-mcp/` |
| Service logs | `/opt/homebrew/var/log/rust-mcp.log` |

### User Config Directory (`~/.config/odoo-rust-mcp/`)

Created automatically on first install:

```
~/.config/odoo-rust-mcp/
├── env              # Environment variables (Odoo credentials, auth settings) - EDIT THIS
├── instances.json   # Multi-instance Odoo configuration (default setup)
├── tools.json       # MCP tools definition
├── prompts.json     # MCP prompts definition
└── server.json      # MCP server metadata
```

**Note:** Starting from v0.3.0+, the following environment variables are automatically set:
- `MCP_TOOLS_JSON` - Points to `~/.config/odoo-rust-mcp/tools.json`
- `MCP_PROMPTS_JSON` - Points to `~/.config/odoo-rust-mcp/prompts.json`
- `MCP_SERVER_JSON` - Points to `~/.config/odoo-rust-mcp/server.json`

Default config files are automatically copied from Homebrew share directory if they don't exist.

## Configuration

### Step 1: Edit Odoo Credentials

Open the env file:

```bash
nano ~/.config/odoo-rust-mcp/env
# or
code ~/.config/odoo-rust-mcp/env
```

### Step 2: Configure for Your Odoo Version

**For Odoo 19+ (API Key authentication):**

```bash
ODOO_URL=http://localhost:8069
ODOO_DB=mydb
ODOO_API_KEY=your_api_key_here
```

**For Odoo 18 or earlier (Username/Password):**

```bash
ODOO_URL=http://localhost:8069
ODOO_DB=mydb
ODOO_VERSION=18
ODOO_USERNAME=admin
ODOO_PASSWORD=your_password
```

### Step 3: (Optional) Enable HTTP Authentication

**Option 1: Via Config UI (Recommended)**
1. Start the service: `brew services start rust-mcp`
2. Open `http://localhost:3008` and login (default: `admin` / `changeme`)
3. Go to **Security** tab
4. Toggle **Enable MCP HTTP Authentication**
5. Click **Generate New Token** (or paste existing token)
6. Changes apply immediately (no restart needed)

**Option 2: Via Environment Variables**
For production, add a secure token:

```bash
# Generate a token
openssl rand -hex 32

# Add to ~/.config/odoo-rust-mcp/env
MCP_AUTH_ENABLED=true
MCP_AUTH_TOKEN=your_generated_token_here
```

Then restart the service:
```bash
brew services restart rust-mcp
```

### Step 4: Config UI Authentication

The Config UI requires login credentials. Default credentials are:
- Username: `admin`
- Password: `changeme`

**IMPORTANT:** Change the default password immediately after first login:
1. Open `http://localhost:3008`
2. Login with default credentials
3. Go to **Security** tab
4. Update username and/or password

Credentials are stored in `~/.config/odoo-rust-mcp/env`:
```bash
CONFIG_UI_USERNAME=admin
CONFIG_UI_PASSWORD=your-secure-password
```

## Running the Server

### Option A: Background Service (Recommended)

```bash
# Start service
brew services start rust-mcp

# Check status
brew services list

# View logs
tail -f /opt/homebrew/var/log/rust-mcp.log

# Stop service
brew services stop rust-mcp

# Restart after config changes
brew services restart rust-mcp
```

Service runs on:
- MCP Server: `http://127.0.0.1:8787/mcp`
- Config UI: `http://127.0.0.1:3008` (login required)

### Option B: Run Manually

```bash
# HTTP mode (for remote clients)
rust-mcp --transport http --listen 127.0.0.1:8787

# Stdio mode (for Cursor/Claude Desktop)
rust-mcp --transport stdio
```

## Cursor IDE Configuration

Add to `~/.cursor/mcp.json`:

**Using HTTP (when service is running):**

```json
{
  "mcpServers": {
    "odoo": {
      "url": "http://127.0.0.1:8787/mcp"
    }
  }
}
```

**Using HTTP with Bearer Token (if MCP auth is enabled):**

```json
{
  "mcpServers": {
    "odoo": {
      "url": "http://127.0.0.1:8787/mcp",
      "headers": {
        "Authorization": "Bearer your-secure-random-token-here"
      }
    }
  }
}
```

**Using stdio (direct):**

```json
{
  "mcpServers": {
    "odoo": {
      "type": "stdio",
      "command": "/opt/homebrew/bin/rust-mcp-service",
      "args": ["--transport", "stdio"]
    }
  }
}
```

Note: Use `rust-mcp-service` (not `rust-mcp`) to auto-load your env file.

## Claude Desktop Configuration

Add to your Claude Desktop config:

```json
{
  "mcpServers": {
    "odoo": {
      "command": "/opt/homebrew/bin/rust-mcp-service",
      "args": ["--transport", "stdio"]
    }
  }
}
```

## Uninstall

```bash
# Stop service first
brew services stop rust-mcp

# Uninstall
brew uninstall rust-mcp

# Remove tap (optional)
brew untap rachmataditiya/odoo-rust-mcp

# Remove config files (optional)
rm -rf ~/.config/odoo-rust-mcp
```

## Troubleshooting

### Service won't start

1. Check if credentials are configured:
   ```bash
   cat ~/.config/odoo-rust-mcp/env
   ```

2. Check logs:
   ```bash
   tail -100 /opt/homebrew/var/log/rust-mcp.log
   ```

3. Try running manually to see errors:
   ```bash
   rust-mcp-service --transport http --listen 127.0.0.1:8787
   ```

### Connection refused

1. Ensure service is running:
   ```bash
   brew services list | grep rust-mcp
   ```

2. Check if port 8787 is in use:
   ```bash
   lsof -i :8787
   ```

### Odoo authentication errors

1. Verify your credentials in `~/.config/odoo-rust-mcp/env`
2. For Odoo 19+: Ensure you have a valid API key
3. For Odoo < 19: Ensure `ODOO_VERSION` is set correctly

## More Information

- Main repository: https://github.com/rachmataditiya/odoo-rust-mcp
- Report issues: https://github.com/rachmataditiya/odoo-rust-mcp/issues
