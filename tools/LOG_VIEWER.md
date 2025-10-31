# MCP Log Viewer

A visual tool for analyzing MCP server logs from the Ubuntu Shell MCP extension.

## Overview

The MCP Log Viewer is a standalone HTML application that helps you understand what's happening in your MCP server sessions. It parses and displays log files in an easy-to-read format with filtering, search, and detailed inspection capabilities.

## Features

### 📊 Statistics Dashboard
- Total log entries count
- Breakdown by type: Client Messages, Server Messages, Commands, Lifecycle Events
- Quick overview of your session activity

### 🔍 Smart Filtering
- **All**: View all entries in chronological order
- **Lifecycle**: Server startup, shutdown, and connection events
- **Client**: Messages sent from Claude to the MCP server
- **Server**: Responses from the MCP server to Claude
- **Commands Only**: Shows bash commands paired with their results (combined view)

### 🎨 Color-Coded Display
- 🔵 Blue: Client messages (requests from Claude)
- 🟢 Green: Server messages (responses to Claude)
- ⚫ Gray: Lifecycle events (server state changes)

### 📝 Detailed Inspection
- Click any entry to see full details
- Extracted command and result display
- Toggle between formatted and raw views
- Full JSON data viewer for protocol messages
- Request/Response ID tracking for matching pairs

### ⚡ Performance
- Handles log files up to 1MB
- Instant filtering and search
- No server required - runs entirely in your browser

## Usage

### Finding Your Log File

MCP server logs are stored in Claude Desktop's logs directory:

**Windows:**
```
C:\Users\[YourUsername]\AppData\Roaming\Claude\logs\mcp-server-ubuntu-shell-mcp.log
```

### Opening the Log Viewer

1. **Open the HTML file** in your browser:
   - Navigate to `ubuntu-shell-mcp-ssh2/tools/`
   - Double-click `mcp-log-viewer.html`
   - Or drag and drop it into your browser

2. **Upload your log file**:
   - Click the "Browse..." button
   - Select your `mcp-server-ubuntu-shell-mcp.log` file
   - The viewer will parse and display it instantly

3. **Explore your logs**:
   - Use the filter buttons to focus on specific types
   - Search for specific commands, errors, or text
   - Click entries to see detailed information

## Understanding the Log Structure

### Entry Types

**Lifecycle Events**
Messages about the server's operational state:
- `Shutting down server...`
- `Initializing server...`
- `Server started and connected successfully`
- `Server transport closed`

**Client Messages**
JSON-RPC requests from Claude to the MCP server:
- Tool calls (command execution requests)
- Initialization requests
- List operations (tools, resources, prompts)

**Server Messages**
JSON-RPC responses from the MCP server:
- Command execution results
- Tool lists
- Error messages

**Commands (Combined View)**
When you select "Commands Only", each entry shows:
- The bash command that was executed
- A preview of the result
- Full details when clicked (command + complete output)

### Log Entry Format

Each log entry follows this pattern:
```
2025-10-31T18:52:13.780Z [ubuntu-shell-mcp] [info] Message... { metadata: undefined }
```

Components:
- **Timestamp**: ISO 8601 format (UTC)
- **Server Name**: `[ubuntu-shell-mcp]`
- **Log Level**: `[info]`, `[error]`, `[warn]`, `[debug]`
- **Message**: Descriptive text or JSON-RPC payload
- **Metadata**: Additional context (currently undefined)

### Request/Response Matching

Commands and responses are matched by their JSON-RPC `id` field:

```json
// Request (client) - ID: 4
{"method":"tools/call","params":{"name":"bash","arguments":{"command":"whoami"}},"jsonrpc":"2.0","id":4}

// Response (server) - ID: 4
{"result":{"content":[{"type":"text","text":"carlos\n\n(exit code: 0)"}]},"jsonrpc":"2.0","id":4}
```

The "Commands Only" filter automatically pairs these together.

## Use Cases

### Debugging Issues

**Connection Problems:**
1. Filter by "Lifecycle" to see connection events
2. Look for "SSH connection failed" or timeout messages
3. Check timestamps to understand timing issues

**Command Failures:**
1. Filter by "Commands Only"
2. Find the failing command
3. Inspect the error message in the result
4. Check exit codes (non-zero = error)

**Performance Analysis:**
1. Compare timestamps between request and response
2. Identify slow commands (>1 second between paired entries)
3. Look for patterns in slow operations

### Understanding Session Flow

1. **Session Start:**
   - Look for "Initializing server..." messages
   - Check SSH connection establishment
   - Verify successful startup

2. **Command Execution:**
   - Filter "Commands Only" to see all executed commands
   - Review command history chronologically
   - Check for patterns in usage

3. **Session End:**
   - Look for "Shutting down server..." messages
   - Verify graceful closure

### Audit Trail

The log viewer provides a complete audit trail of:
- Every command executed on the remote server
- Exact timestamp of each operation
- Full command output and exit codes
- Session duration and activity

This is useful for:
- Security auditing
- Compliance requirements
- Debugging historical issues
- Understanding usage patterns

## Tips

### Effective Filtering

- Start with "All" to get the big picture
- Use "Commands Only" to focus on actual work done
- Filter by "Client" or "Server" to debug protocol issues
- Use "Lifecycle" to understand connection behavior

### Search Tips

The search box searches across:
- Timestamps
- Command text
- Command output
- JSON-RPC payloads
- Error messages

Search examples:
- `"error"` - Find all errors
- `"sudo"` - Find sudo usage
- `"ls -la"` - Find directory listings
- `"exit code: 1"` - Find failed commands

### Analyzing Command Patterns

1. Export commands to understand usage:
   - Filter "Commands Only"
   - Review the list of commands
   - Identify common patterns

2. Look for inefficiencies:
   - Multiple similar commands
   - Commands that could be combined
   - Unnecessary operations

## Technical Details

### Browser Compatibility

Tested and working on:
- ✅ Chrome/Edge (recommended)
- ✅ Firefox
- ✅ Safari

Requirements:
- Modern browser with ES6 support
- JavaScript enabled
- No internet connection required (all resources are CDN-based but cached)

### Privacy & Security

- Runs entirely client-side in your browser
- No data sent to any server
- No analytics or tracking
- Log file is only loaded into memory
- Close browser to clear log from memory

### File Size Limits

- Maximum file size: 1MB
- Larger files will be rejected with an alert
- Most MCP sessions produce logs well under this limit
- If you need to analyze larger files, manually split them

### Performance

- Parsing: Instant (<100ms for typical logs)
- Filtering: Real-time as you type
- Search: Instant across all entries
- Memory: ~2-3x the file size in browser memory

## Troubleshooting

**"File is too large! Maximum size is 1MB"**
- Your log file exceeds 1MB
- Solution: Split the file or analyze only recent entries

**No entries appear after upload**
- Check browser console (F12) for parsing errors
- Verify file is actually a valid MCP log file
- Try with a different log file

**Browser freezes when uploading**
- File may be corrupted or malformed
- Browser may be low on memory
- Try refreshing and uploading again

**Search not working**
- Clear search box and try again
- Check console for JavaScript errors
- Try refreshing the page

## Integration with Development Workflow

### During Development

1. Keep log viewer open in a browser tab
2. Make changes to your MCP server
3. Test commands in Claude
4. Reload log file in viewer to see latest entries
5. Analyze behavior and debug issues

### CI/CD Pipeline

The log viewer can be used in automated testing:
1. Run test suite that generates logs
2. Use headless browser to load logs
3. Parse and validate expected patterns
4. Fail build if errors detected

## Future Enhancements

Potential improvements for future versions:
- Export filtered results to CSV/JSON
- Multiple file comparison
- Timeline view with zoom
- Advanced filtering with regex
- Dark mode theme
- Command performance metrics
- Error rate graphs
- Session statistics

## License

MIT License - Same as the Ubuntu Shell MCP extension

## Support

For issues or questions:
1. Check this documentation
2. Review the main README.md
3. Open an issue on GitHub
4. Include sample log entries that demonstrate the issue

---

**Note**: This is a development and debugging tool. It's not required for normal use of the Ubuntu Shell MCP extension - it's here to help you understand and troubleshoot your MCP sessions.
