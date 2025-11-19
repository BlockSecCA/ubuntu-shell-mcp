@echo off
REM Cleanup Old Archives - Batch launcher

echo Starting MCP Archive Cleanup...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0cleanup-old-archives.ps1"

echo.
pause
