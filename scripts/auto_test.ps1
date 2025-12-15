<#
Automated local test for GUI project.
- Builds using `tools\mingw64\bin\g++.exe` if present, else uses `g++` on PATH.
- Runs the built exe with `GUI_AUTO_START=1` and waits up to 20s for it to exit.
- Returns non-zero on build or run failure.
#>
$ErrorActionPreference = 'Stop'
Write-Host "Starting auto-test..."
$cwd = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $cwd\..\
try {
    # Ensure build dir
    if (-not (Test-Path build)) { New-Item -ItemType Directory -Path build | Out-Null }

    # Choose g++
    $gpp = "$PWD\tools\mingw64\bin\g++.exe"
    if (-not (Test-Path $gpp)) {
        $gpp = "g++"
    }
    Write-Host "Using g++: $gpp"

    $cmd = "`"$gpp`" -o build\gui.exe src\main.cpp src\gui.cpp -I include -static -lcomctl32 -lgdi32 -luser32"
    Write-Host "Building: $cmd"
    $proc = Start-Process -FilePath $gpp -ArgumentList "-o","build\gui.exe","src\main.cpp","src\gui.cpp","-I","include","-static","-lcomctl32","-lgdi32","-luser32" -NoNewWindow -Wait -PassThru
    if ($proc.ExitCode -ne 0) { Write-Error "Build failed (exit $($proc.ExitCode))"; exit 2 }

    if (-not (Test-Path build\gui.exe)) { Write-Error "Executable not found after build"; exit 3 }

    Write-Host "Running build\gui.exe with GUI_AUTO_START=1"
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "$PWD\build\gui.exe"
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.EnvironmentVariables['GUI_AUTO_START'] = '1'

    $procRun = [System.Diagnostics.Process]::Start($startInfo)

    $timeout = 20000 # ms
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while (-not $procRun.HasExited -and $sw.ElapsedMilliseconds -lt $timeout) {
        Start-Sleep -Milliseconds 200
    }
    if (-not $procRun.HasExited) {
        try { $procRun.Kill() } catch { }
        Write-Error "Process did not exit within $timeout ms"
        exit 4
    }
    Write-Host "Process exited with code $($procRun.ExitCode)"
    if ($procRun.ExitCode -ne 0) { Write-Error "Process failed with exit code $($procRun.ExitCode)"; exit 5 }

    Write-Host "Auto-test succeeded"
    exit 0
} finally {
    Pop-Location
}
