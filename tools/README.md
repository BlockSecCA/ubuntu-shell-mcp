# Tools Directory

This directory contains utilities for working with the Ubuntu Shell MCP extension.

## MCP Log Viewer

**File:** `mcp-log-viewer.html`

A standalone web application for analyzing MCP server logs.

### Quick Start

1. **Open in browser:** Double-click `mcp-log-viewer.html`
2. **Find your log:** `C:\Users\[You]\AppData\Roaming\Claude\logs\mcp-server-ubuntu-shell-mcp.log`
3. **Upload and analyze:** Click Browse, select the log file, explore!

### What You Can Do

- View all commands executed in your session
- See request/response pairs matched by ID
- Filter by type (Lifecycle, Client, Server, Commands)
- Search for specific commands or errors
- Inspect full JSON-RPC payloads
- Track timestamps to analyze performance

### When to Use It

- **Debugging**: Find out why a command failed
- **Performance**: See how long commands take
- **Auditing**: Review what commands were executed
- **Learning**: Understand the MCP protocol flow

### Documentation

See [LOG_VIEWER.md](LOG_VIEWER.md) for comprehensive documentation including:
- Detailed feature descriptions
- Understanding log structure
- Use cases and tips
- Troubleshooting guide

---

## Future Tools

This directory may contain additional development utilities in the future, such as:
- Configuration validators
- Performance analyzers
- Connection testers
- Log formatters
