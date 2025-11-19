# cleanup-old-archives.ps1
# Deletes archived log files older than specified days

param(
    [int]$DaysToKeep = 30
)

$archiveDir = "$env:APPDATA\Claude\logs\archive"

Write-Host "MCP Archive Cleanup" -ForegroundColor Cyan
Write-Host "==================`n" -ForegroundColor Cyan

if (-not (Test-Path $archiveDir)) {
    Write-Host "Archive directory does not exist: $archiveDir" -ForegroundColor Yellow
    exit
}

$cutoffDate = (Get-Date).AddDays(-$DaysToKeep)
Write-Host "Removing archives older than: $($cutoffDate.ToString('yyyy-MM-dd'))" -ForegroundColor White
Write-Host "Days to keep: $DaysToKeep`n" -ForegroundColor White

$oldFiles = Get-ChildItem "$archiveDir\*.log" | 
    Where-Object { $_.LastWriteTime -lt $cutoffDate }

if ($oldFiles.Count -eq 0) {
    Write-Host "No old archives found to delete.`n" -ForegroundColor Green
    exit
}

Write-Host "Found $($oldFiles.Count) old archives:`n" -ForegroundColor Yellow

foreach ($file in $oldFiles) {
    $age = [math]::Round(((Get-Date) - $file.LastWriteTime).TotalDays, 1)
    Write-Host "  Deleting: $($file.Name) (${age} days old)" -ForegroundColor Gray
    Remove-Item $file.FullName
}

Write-Host "`nCleanup complete! Deleted $($oldFiles.Count) files.`n" -ForegroundColor Green
