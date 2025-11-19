# archive-mcp-logs.ps1
# Archives ALL Claude log files by date into archive/ subfolder
# Supports both ISO timestamps (MCP logs) and simple timestamps (main.log, etc.)

$logDir = "$env:APPDATA\Claude\logs"
$archiveDir = "$logDir\archive"
$stateFile = "$logDir\.mcp-archive-state.json"

Write-Host "Claude Log Archiver" -ForegroundColor Cyan
Write-Host "===================`n" -ForegroundColor Cyan

# Create archive directory if it doesn't exist
if (-not (Test-Path $archiveDir)) {
    New-Item -ItemType Directory -Path $archiveDir | Out-Null
    Write-Host "Created archive directory: $archiveDir`n" -ForegroundColor Green
}

# Load state
if (Test-Path $stateFile) {
    $state = Get-Content $stateFile | ConvertFrom-Json
} else {
    $state = @{}
}

# Process all .log files in the main directory
$logFiles = Get-ChildItem "$logDir\*.log" -File
$totalProcessed = 0
$totalDates = 0

foreach ($logFile in $logFiles) {
    $logName = $logFile.Name
    
    # Get last processed line for this specific log file
    $lastLine = 0
    if ($state.PSObject.Properties.Name -contains $logName) {
        $lastLine = $state.$logName.lastProcessedLine
    }
    
    # Read new lines from this log file
    $allLines = Get-Content $logFile.FullName
    $newLines = $allLines | Select-Object -Skip $lastLine
    
    if ($newLines.Count -eq 0) {
        Write-Host "  $logName - No new entries" -ForegroundColor Gray
        continue
    }
    
    # Group by date - handle both timestamp formats
    $byDate = @{}
    $skippedLines = 0
    
    foreach ($line in $newLines) {
        $date = $null
        
        # Try ISO format first: 2025-11-12T16:19:01.310Z
        if ($line -match '^(\d{4}-\d{2}-\d{2})T') {
            $date = $matches[1]
        }
        # Try simple format: 2025-11-12 11:18:59
        elseif ($line -match '^(\d{4}-\d{2}-\d{2})\s') {
            $date = $matches[1]
        }
        
        if ($date) {
            if (-not $byDate.ContainsKey($date)) {
                $byDate[$date] = @()
            }
            $byDate[$date] += $line
        } else {
            $skippedLines++
        }
    }
    
    # Append to dated archive logs
    foreach ($date in $byDate.Keys) {
        # Extract the base name without extension for the archive file
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($logName)
        $dateLog = "$archiveDir\$baseName-$date.log"
        $byDate[$date] | Add-Content $dateLog
    }
    
    # Update state for this log file
    if (-not ($state.PSObject.Properties.Name -contains $logName)) {
        $state | Add-Member -NotePropertyName $logName -NotePropertyValue @{} -Force
    }
    
    $state.$logName = @{
        lastProcessedLine = $allLines.Count
        lastProcessedTimestamp = (Get-Date).ToString("o")
        lastArchivedDate = ($byDate.Keys | Sort-Object | Select-Object -Last 1)
    }
    
    $totalProcessed += $newLines.Count
    $totalDates += $byDate.Keys.Count
    
    $statusMsg = "  $logName - $($newLines.Count) lines -> $($byDate.Keys.Count) dates"
    if ($skippedLines -gt 0) {
        $statusMsg += " ($skippedLines skipped)"
        Write-Host $statusMsg -ForegroundColor Yellow
    } else {
        Write-Host $statusMsg -ForegroundColor Green
    }
}

# Save state
$state | ConvertTo-Json -Depth 3 | Set-Content $stateFile

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  Total archived: $totalProcessed lines" -ForegroundColor White
Write-Host "  From: $($logFiles.Count) log files" -ForegroundColor White
Write-Host "  Into: $totalDates dated archives" -ForegroundColor White
Write-Host "  Location: $archiveDir`n" -ForegroundColor White
