# MCP Log Rotation Scripts

Utilities for managing and archiving MCP server logs.

## Files

### PowerShell Scripts
- `archive-mcp-logs.ps1` - Archives all .log files by date into archive/ subfolder
- `cleanup-old-archives.ps1` - Deletes archived logs older than 30 days

### Batch Files (Double-click to run)
- `archive-logs.bat` - Archive current logs
- `cleanup-archives.bat` - Cleanup old archives
- `archive-and-cleanup.bat` - Do both in one go

## How It Works

### Archiving
1. Reads all `*.log` files in `%APPDATA%\Claude\logs\`
2. Groups log entries by date (from timestamps)
3. Creates dated archive files: `mcp-server-name-2024-10-31.log`
4. Stores archives in `%APPDATA%\Claude\logs\archive\`
5. Tracks progress in `.mcp-archive-state.json` (no duplicates)

### Cleanup
- Deletes archives older than 30 days
- Keeps your archive folder manageable
- Configurable retention period

## Usage

### Quick Start
Just double-click: **`archive-and-cleanup.bat`**

### Individual Operations
- **Archive only**: Double-click `archive-logs.bat`
- **Cleanup only**: Double-click `cleanup-archives.bat`

### Command Line
```powershell
# Archive logs
.\archive-mcp-logs.ps1

# Cleanup with custom retention (e.g., 60 days)
.\cleanup-old-archives.ps1 -DaysToKeep 60
```

## Directory Structure

```
%APPDATA%\Claude\logs\
├── mcp-server-ubuntu-shell-mcp.log      (active)
├── mcp-server-filesystem.log            (active)
├── .mcp-archive-state.json              (tracker)
└── archive/
    ├── mcp-server-ubuntu-shell-mcp-2024-10-31.log
    ├── mcp-server-ubuntu-shell-mcp-2024-11-01.log
    ├── mcp-server-filesystem-2024-10-31.log
    └── ...
```

## Features

✅ **Idempotent** - Run multiple times safely, no duplicates  
✅ **Multi-log** - Handles all MCP server logs automatically  
✅ **Incremental** - Only processes new log entries  
✅ **Safe** - Read-only operation on active logs  
✅ **Clean** - Keeps main log directory uncluttered  

## Workflow

1. **Work normally** - MCP servers write to active logs
2. **Archive periodically** - Run `archive-logs.bat` (daily/weekly)
3. **Use log viewer** - Analyze archived logs by date
4. **Cleanup old archives** - Run `cleanup-archives.bat` (monthly)

## Scheduling (Optional)

To run automatically:

1. Open **Task Scheduler**
2. Create new task: "Archive MCP Logs"
3. Trigger: Daily at 2am (or on user logon)
4. Action: Run `archive-and-cleanup.bat`
5. Settings: "Run whether user is logged on or not"

## Notes

- Active logs remain untouched (safe to run anytime)
- Archives are append-only (no data loss)
- State file prevents duplicate entries
- Works with any MCP server log format

## Troubleshooting

**"No new entries"**  
- Normal! Means logs are already archived

**"Archive directory does not exist"**  
- Run archive script first to create it

**Script won't run**  
- Right-click .bat file → "Run as administrator"
- Or: Open PowerShell as admin and run .ps1 directly

## Integration with Log Viewer

After archiving, use the MCP Log Viewer to:
1. Select archived logs by date
2. Filter by time range within the archive
3. Analyze specific sessions

See `mcp-log-viewer.html` for the viewer tool.
