@echo off
REM Archive MCP Logs - Batch launcher

echo Starting MCP Log Archiver...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0archive-mcp-logs.ps1"

echo.
pause
