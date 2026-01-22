# Homebrew Tap for odoo-rust-mcp

This is the official Homebrew tap for [odoo-rust-mcp](https://github.com/rachmataditiya/odoo-rust-mcp) - a Model Context Protocol (MCP) server for Odoo integration.

## Installation

```bash
# Add this tap
brew tap rachmataditiya/odoo-rust-mcp

# Install rust-mcp
brew install rust-mcp
```

Or install directly:

```bash
brew install rachmataditiya/odoo-rust-mcp/rust-mcp
```

## Usage

After installation, you can run the MCP server:

```bash
# Run in stdio mode (for Cursor/Claude Desktop)
rust-mcp --transport stdio

# Run as HTTP server
rust-mcp --transport http --listen 127.0.0.1:8787
```

## Configuration

Set environment variables for Odoo connection:

### Odoo 19+ (API Key authentication)
```bash
export ODOO_URL=http://localhost:8069
export ODOO_DB=mydb
export ODOO_API_KEY=your_api_key
```

### Odoo < 19 (Username/Password authentication)
```bash
export ODOO_URL=http://localhost:8069
export ODOO_DB=mydb
export ODOO_VERSION=18
export ODOO_USERNAME=admin
export ODOO_PASSWORD=admin
```

## More Information

For detailed documentation, see the main repository: https://github.com/rachmataditiya/odoo-rust-mcp
