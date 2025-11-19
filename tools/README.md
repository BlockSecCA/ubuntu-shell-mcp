# Claude Desktop Log Management Tools

Comprehensive toolset for managing, viewing, and archiving logs from Claude Desktop application and MCP servers.

## 📋 Overview

Claude Desktop generates multiple log files in different formats. This toolset provides universal handling for all log types:

- **Log Viewer**: Interactive web-based viewer for analyzing logs
- **Archive Scripts**: Automated log rotation and archival by date
- **Documentation**: Complete reference for all log formats

## 🚀 Quick Start

### View Logs
1. Open `mcp-log-viewer-universal.html` in your browser
2. Drag and drop any `.log` file from `%APPDATA%\Claude\logs\`
3. Use filters to explore MCP protocol messages, commands, and app events

### Archive Logs
```powershell
cd C:\Users\YourName\code\ubuntu-shell-mcp\tools
.\archive-mcp-logs.ps1
```

## 📂 File Overview

### Core Tools

| File | Purpose | Status |
|------|---------|--------|
| `mcp-log-viewer-universal.html` | Universal log viewer (all formats) | ✅ Recommended |
| `mcp-log-viewer.html` | Original MCP-only viewer | 🔄 Legacy |
| `archive-mcp-logs.ps1` | Archive all logs by date | ✅ Recommended |
| `cleanup-old-archives.ps1` | Clean up old archived logs | ✅ Active |

### Batch Helpers

| File | Purpose |
|------|---------|
| `archive-logs.bat` | Quick launcher for archive script |
| `cleanup-archives.bat` | Quick launcher for cleanup script |
| `archive-and-cleanup.bat` | Run both operations |

### Documentation

| File | Contents |
|------|----------|
| `CLAUDE_LOG_FORMATS.md` | Complete log format reference |
| `LOG_VIEWER.md` | Detailed viewer usage guide |
| `LOG_ROTATION_README.md` | Log rotation best practices |
| `UPDATES_SUMMARY.md` | Recent changes and migration guide |
| `COMPLETION_STATUS.md` | Development status and testing checklist |

## 📊 Supported Log Formats

### Format 1: MCP Server Logs (Individual)
**Files**: `mcp-server-*.log`  
**Format**: `2025-11-12T16:19:01.312Z [server-name] [info] Message`  
**Contains**: Detailed MCP protocol messages, tool calls, JSON-RPC

### Format 2: MCP Unified Log
**Files**: `mcp.log`  
**Format**: `2025-11-12T16:19:01.310Z [info] [server-name] Message`  
**Contains**: All MCP server events in one file

### Format 3: Claude Desktop Main Log
**Files**: `main.log`  
**Format**: `2025-11-12 11:18:58 [info] Message`  
**Contains**: App lifecycle, extensions, updates

### Format 4: Web/Window Logs
**Files**: `claude.ai-web.log`, `unknown-window.log`  
**Format**: `2025-11-12 11:18:59 [warn] Message`  
**Contains**: Browser errors, CSP violations

## 🛠️ Tools Detail

### Universal Log Viewer (`mcp-log-viewer-universal.html`)

**Features**:
- ✅ Parses all 4 log formats automatically
- ✅ Extracts and displays MCP JSON-RPC messages
- ✅ Filter by: message type, server name, log level, time range
- ✅ Command-only view for quick analysis
- ✅ Statistics dashboard
- ✅ Refresh capability for active logs
- ✅ Raw vs formatted view toggle

**Usage**:
1. Open in any modern browser (Chrome, Firefox, Edge)
2. Drag/drop log file or use file picker
3. Use filters to narrow down to what you need
4. Click entries for detailed JSON view
5. Use time range for focused analysis

**Tips**:
- For active logs: use Refresh button to reload
- For command analysis: use "Commands Only" filter
- For debugging: check browser console for parse errors
- Max file size: 5MB (browser limitation)

### Archive Script (`archive-mcp-logs.ps1`)

**Features**:
- ✅ Handles both ISO and simple timestamp formats
- ✅ Archives all log types by date
- ✅ Incremental processing (only new lines)
- ✅ State tracking (remembers last processed position)
- ✅ Creates dated files: `{basename}-YYYY-MM-DD.log`
- ✅ Reports statistics

**How It Works**:
1. Reads all `.log` files in `%APPDATA%\Claude\logs\`
2. Extracts date from each log line
3. Groups lines by date
4. Appends to dated archive files in `archive/` subdirectory
5. Saves state to avoid reprocessing

**State File**: `.mcp-archive-state.json` tracks:
- Last processed line number per log file
- Last processing timestamp
- Last archived date

**Output Structure**:
```
%APPDATA%\Claude\logs\
├── archive/
│   ├── mcp-server-ubuntu-shell-mcp-2025-11-12.log
│   ├── mcp-server-ubuntu-shell-mcp-2025-11-13.log
│   ├── mcp-2025-11-12.log
│   ├── main-2025-11-12.log
│   └── claude.ai-web-2025-11-12.log
└── .mcp-archive-state.json
```

### Cleanup Script (`cleanup-old-archives.ps1`)

**Features**:
- Removes archived logs older than specified retention period
- Default: keeps last 30 days
- Dry-run mode available
- Detailed reporting

**Usage**:
```powershell
# Keep last 30 days (default)
.\cleanup-old-archives.ps1

# Keep last 7 days
.\cleanup-old-archives.ps1 -DaysToKeep 7

# Preview what would be deleted
.\cleanup-old-archives.ps1 -DaysToKeep 30 -WhatIf
```

## 📅 Recommended Workflow

### Daily (Automated via Task Scheduler)
```powershell
# Morning: Archive yesterday's logs
.\archive-mcp-logs.ps1
```

### Weekly
```powershell
# Review archived logs if needed
# Cleanup old archives
.\cleanup-old-archives.ps1
```

### When Troubleshooting
1. Open `mcp-log-viewer-universal.html`
2. Load the relevant log file
3. Use filters to narrow down timeframe
4. Review MCP messages or app events
5. Check for errors or unexpected behavior

## 🔧 Setup Task Scheduler (Optional)

To automate daily archiving:

```powershell
# Create a scheduled task that runs daily at 2 AM
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File C:\Users\YourName\code\ubuntu-shell-mcp\tools\archive-mcp-logs.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 2am

Register-ScheduledTask -TaskName "Archive Claude Logs" `
    -Action $action -Trigger $trigger -Description "Daily Claude log archival"
```

## 📈 Log File Sizes

Typical sizes (will vary based on usage):
- `mcp-server-*.log`: 100KB - 5MB per day
- `mcp.log`: 200KB - 10MB per day
- `main.log`: 50KB - 2MB per day
- Web logs: 10KB - 500KB per day

**Recommendation**: Archive daily if logs exceed 10MB

## 🐛 Troubleshooting

### Viewer shows "Failed to parse" messages
**Solution**: Check browser console for the unparsed line format. May indicate a new log format not yet supported.

### Archive script reports many skipped lines
**Cause**: Log lines don't match expected timestamp formats  
**Solution**: Review skipped lines to identify new formats. Update regex patterns if needed.

### Large log files crash browser
**Limitation**: Browser memory constraints  
**Solution**: Archive and view dated logs instead, or use command-line tools for very large files

### Archive script doesn't process recent entries
**Cause**: State file may be corrupted  
**Solution**: Delete `.mcp-archive-state.json` and re-run (will reprocess entire log)

## 🔍 Advanced Usage

### Viewing Specific Time Ranges
1. Open viewer
2. Load log file
3. Use "Time Range" filter
4. Select start/end dates
5. Or use quick filters (Last Hour, Last 3 Hours, etc.)

### Analyzing MCP Commands
1. Open viewer with MCP server log
2. Click "Commands Only" filter
3. Review tool call sequences
4. Click entries to see full JSON payloads

### Correlating Multiple Logs
1. Note timestamp from one log
2. Open corresponding log in new browser tab
3. Use time range filter to find related events
4. Compare server-side vs client-side view

### Exporting Data
- Browser: Use "Select All" in raw view, copy/paste
- PowerShell: Use archived dated logs with standard text tools
- Future: CSV/JSON export planned

## 📚 Further Reading

- **Log Formats**: See `CLAUDE_LOG_FORMATS.md` for detailed format specifications
- **Viewer Guide**: See `LOG_VIEWER.md` for advanced viewer features
- **Recent Updates**: See `UPDATES_SUMMARY.md` for what changed in v2
- **Testing**: See `COMPLETION_STATUS.md` for testing checklist

## 🤝 Contributing

This toolset is part of the Ubuntu Shell MCP project. Improvements welcome:

1. **New Log Formats**: If Claude adds new log types, update parsers
2. **Performance**: Large file handling optimizations
3. **Features**: Export, real-time viewing, log correlation
4. **Documentation**: Screenshots, examples, tutorials

## 📝 Version History

### v2.0 (2025-11-19)
- ✅ Universal viewer supports all log formats
- ✅ Archive script handles both timestamp formats
- ✅ Comprehensive documentation
- ✅ Format reference guide

### v1.0 (Original)
- MCP log viewer (server logs only)
- Basic archive script (simple timestamps only)
- Initial documentation

## 🏷️ License

Part of the Ubuntu Shell MCP project - see main repository for license details.

## 📧 Support

For issues or questions:
1. Check troubleshooting section above
2. Review documentation files
3. Check browser console for errors
4. Verify log file format matches expected patterns

---

**Location**: `~/code/ubuntu-shell-mcp/tools/`  
**Log Directory**: `%APPDATA%\Claude\logs\`  
**Archive Directory**: `%APPDATA%\Claude\logs\archive\`

**Last Updated**: 2025-11-19
