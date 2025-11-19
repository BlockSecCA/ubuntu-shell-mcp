@echo off
REM Archive and Cleanup - Combined launcher

echo MCP Log Management
echo ==================
echo.
echo Step 1: Archiving logs...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0archive-mcp-logs.ps1"

echo.
echo Step 2: Cleaning up old archives...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0cleanup-old-archives.ps1"

echo.
echo All done!
echo.
pause
