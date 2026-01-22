class RustMcp < Formula
  desc "Odoo MCP Server - Model Context Protocol server for Odoo integration"
  homepage "https://github.com/rachmataditiya/odoo-rust-mcp"
  version "0.2.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/rachmataditiya/odoo-rust-mcp/releases/download/v#{version}/rust-mcp-aarch64-apple-darwin.tar.gz"
      sha256 "10f0d6020a46ec8bc7f033cefab0f429b8444b24313bed0bddbd741e1043bfec"
    end

    if Hardware::CPU.intel?
      url "https://github.com/rachmataditiya/odoo-rust-mcp/releases/download/v#{version}/rust-mcp-x86_64-apple-darwin.tar.gz"
      sha256 "ded0d2b223275243d9c2ef123ebea0d1ab7f1125cd7efd3454e97ae640144b63"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/rachmataditiya/odoo-rust-mcp/releases/download/v#{version}/rust-mcp-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "29bab1bc94d47e73eab64bb05a26136442ad0af9dad9bb54bd3a3663b2b08714"
    end
  end

  def install
    bin.install "rust-mcp"
    # Install config files to share directory (defaults)
    (share/"odoo-rust-mcp").install Dir["config/*"] if Dir.exist?("config")
    # Install example env file
    (share/"odoo-rust-mcp").install ".env.example" if File.exist?(".env.example")

    # Create wrapper script content
    wrapper_content = <<~EOS
      #!/bin/bash
      CONFIG_DIR="$HOME/.config/odoo-rust-mcp"
      
      # Create config directory if it doesn't exist
      if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        echo "Created config directory: $CONFIG_DIR"
      fi
      
      # Create default env file if it doesn't exist
      if [ ! -f "$CONFIG_DIR/env" ]; then
        cat > "$CONFIG_DIR/env" << 'ENVEOF'
# Odoo Rust MCP Server Configuration
# Edit this file with your Odoo credentials

# Odoo 19+ (API Key authentication)
ODOO_URL=http://localhost:8069
ODOO_DB=mydb
ODOO_API_KEY=YOUR_API_KEY

# Odoo < 19 (Username/Password authentication)
# ODOO_URL=http://localhost:8069
# ODOO_DB=mydb
# ODOO_VERSION=18
# ODOO_USERNAME=admin
# ODOO_PASSWORD=admin

# MCP Authentication (HTTP transport)
# Generate a secure token: openssl rand -hex 32
# MCP_AUTH_TOKEN=your-secure-random-token-here
ENVEOF
        chmod 600 "$CONFIG_DIR/env"
        echo "Created default env file: $CONFIG_DIR/env"
        echo "Please edit it with your Odoo credentials"
      fi
      
      # Load environment from user config if exists
      if [ -f "$CONFIG_DIR/env" ]; then
        set -a
        source "$CONFIG_DIR/env"
        set +a
      fi
      
      # Set default MCP config paths to Homebrew share if not already set
      export MCP_TOOLS_JSON="${MCP_TOOLS_JSON:-#{HOMEBREW_PREFIX}/share/odoo-rust-mcp/tools.json}"
      export MCP_PROMPTS_JSON="${MCP_PROMPTS_JSON:-#{HOMEBREW_PREFIX}/share/odoo-rust-mcp/prompts.json}"
      export MCP_SERVER_JSON="${MCP_SERVER_JSON:-#{HOMEBREW_PREFIX}/share/odoo-rust-mcp/server.json}"
      
      exec "#{opt_bin}/rust-mcp" "$@"
    EOS

    # Write to libexec first, then install to bin (preserves executable)
    (libexec/"rust-mcp-service").write wrapper_content
    (libexec/"rust-mcp-service").chmod 0755
    bin.install_symlink libexec/"rust-mcp-service"
  end

  # Service configuration for `brew services start rust-mcp`
  # Uses binary directly (v0.2.4+ auto-loads config from ~/.config/odoo-rust-mcp/env)
  service do
    run [opt_bin/"rust-mcp", "--transport", "http", "--listen", "127.0.0.1:8787"]
    keep_alive true
    log_path var/"log/rust-mcp.log"
    error_log_path var/"log/rust-mcp.log"
  end

  def caveats
    <<~EOS
      Configuration directory: ~/.config/odoo-rust-mcp/
      
      The config directory and default env file will be automatically created
      the first time you run 'rust-mcp'.
      
      Quick start:
        1. Run once to create config: rust-mcp --help
        2. Edit credentials: nano ~/.config/odoo-rust-mcp/env
        3. Start service: brew services start rust-mcp

      Service commands:
        brew services start rust-mcp
        brew services stop rust-mcp
        brew services restart rust-mcp

      Service endpoint: http://127.0.0.1:8787/mcp
      Service logs: #{var}/log/rust-mcp.log

      For Cursor IDE configuration:
        See: https://github.com/rachmataditiya/odoo-rust-mcp#readme
    EOS
  end

  test do
    assert_match "rust-mcp", shell_output("#{bin}/rust-mcp --help")
  end
end
