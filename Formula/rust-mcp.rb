class RustMcp < Formula
  desc "Odoo MCP Server - Model Context Protocol server for Odoo integration"
  homepage "https://github.com/rachmataditiya/odoo-rust-mcp"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/rachmataditiya/odoo-rust-mcp/releases/download/v#{version}/rust-mcp-aarch64-apple-darwin.tar.gz"
      sha256 "PLACEHOLDER_SHA256_MACOS_ARM64"
    end

    if Hardware::CPU.intel?
      url "https://github.com/rachmataditiya/odoo-rust-mcp/releases/download/v#{version}/rust-mcp-x86_64-apple-darwin.tar.gz"
      sha256 "PLACEHOLDER_SHA256_MACOS_X64"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/rachmataditiya/odoo-rust-mcp/releases/download/v#{version}/rust-mcp-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "PLACEHOLDER_SHA256_LINUX_X64"
    end
  end

  def install
    bin.install "rust-mcp"
    # Install config files to share directory
    (share/"odoo-rust-mcp").install Dir["config/*"] if Dir.exist?("config")
  end

  def caveats
    <<~EOS
      Config files installed to: #{share}/odoo-rust-mcp

      Usage:
        Run directly (stdio):  rust-mcp --transport stdio
        Run as HTTP server:    rust-mcp --transport http --listen 127.0.0.1:8787

      Set environment variables for Odoo connection:
        ODOO_URL, ODOO_DB, ODOO_API_KEY (Odoo 19+)
        or ODOO_USERNAME, ODOO_PASSWORD, ODOO_VERSION (Odoo < 19)

      Example configuration for Cursor IDE:
        See: https://github.com/rachmataditiya/odoo-rust-mcp#readme
    EOS
  end

  test do
    assert_match "rust-mcp", shell_output("#{bin}/rust-mcp --help")
  end
end
