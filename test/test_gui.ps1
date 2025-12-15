#!/usr/bin/env pwsh
<#
Interactive test script for GUI application.
This script:
1. Starts the GUI application
2. Sends input "1" to start the process
3. Waits for GUI window to appear
4. Displays instructions for manual testing
#>

$exePath = Join-Path $PSScriptRoot '..\build\gui.exe'
if (-not (Test-Path $exePath)) {
    Write-Error "gui.exe not found at $exePath. Build the project first."
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GUI Application Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting gui.exe..." -ForegroundColor Green
Write-Host ""

# Start the GUI application in a new window
$process = Start-Process -FilePath cmd.exe -ArgumentList "/c `"$exePath`"" -PassThru

Write-Host "Process started (PID: $($process.Id))" -ForegroundColor Green
Write-Host ""
Write-Host "Expected behavior:" -ForegroundColor Yellow
Write-Host "  1. A console window should appear showing a menu:"
Write-Host "     - 1. Start Process" -ForegroundColor White
Write-Host "     - 2. Exit" -ForegroundColor White
Write-Host ""
Write-Host "  2. When you enter '1', you should see:" -ForegroundColor Yellow
Write-Host "     - A separate GUI window appears with:" -ForegroundColor White
Write-Host "       * A progress bar (0% -> 100%)" -ForegroundColor White
Write-Host "       * A 'Cancel' button" -ForegroundColor White
Write-Host "     - Progress updates in the progress bar" -ForegroundColor White
Write-Host "     - GUI window appears above the console when console is active" -ForegroundColor White
Write-Host ""
Write-Host "  3. Test cancel:" -ForegroundColor Yellow
Write-Host "     - Click 'Cancel' button during progress" -ForegroundColor White
Write-Host "     - Console should print: 'Process cancelled'" -ForegroundColor White
Write-Host ""
Write-Host "  4. Test completion:" -ForegroundColor Yellow
Write-Host "     - Let progress reach 100%" -ForegroundColor White
Write-Host "     - Console should print: 'Process completed'" -ForegroundColor White
Write-Host "     - Console will wait 2 seconds then exit (no menu will reappear)" -ForegroundColor White
Write-Host ""
Write-Host "  5. Exit:" -ForegroundColor Yellow
Write-Host "     - Enter '2' to exit application" -ForegroundColor White
Write-Host ""
Write-Host "Waiting for process to complete..." -ForegroundColor Cyan
$process.WaitForExit()
Write-Host ""
Write-Host "Test completed. Exit code: $($process.ExitCode)" -ForegroundColor Green
