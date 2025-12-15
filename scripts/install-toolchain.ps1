#!/usr/bin/env pwsh
<#
Downloads portable WinLibs (MinGW-w64) and CMake into ./tools,
adds them to PATH for the current session, and attempts to build the project.

Usage: Run from repository root in PowerShell (no admin required):
  .\scripts\install-toolchain.ps1
#>

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path -Path (Join-Path $PSScriptRoot '..')
$toolsDir = Join-Path $repoRoot 'tools'
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

# Stable URLs (may be updated in future). Change these if you prefer other versions.
$winlibsUrl = 'https://github.com/brechtsanders/winlibs_mingw/releases/download/15.2.0posix-13.0.0-msvcrt-r4/winlibs-x86_64-posix-seh-gcc-15.2.0-mingw-w64msvcrt-13.0.0-r4.zip'
$cmakeUrl = 'https://github.com/Kitware/CMake/releases/download/v4.2.1/cmake-4.2.1-windows-x86_64.zip'

Function Download-File($url, $outPath) {
    Write-Host "Downloading $url -> $outPath"
    if (Test-Path $outPath) { Remove-Item $outPath -Force }
    Invoke-WebRequest -Uri $url -OutFile $outPath -UseBasicParsing
}

try {
    $winlibsZip = Join-Path $toolsDir 'winlibs.zip'
    Download-File $winlibsUrl $winlibsZip
    Write-Host 'Extracting WinLibs...'
    Expand-Archive -Path $winlibsZip -DestinationPath $toolsDir -Force

    $cmakeZip = Join-Path $toolsDir 'cmake.zip'
    Download-File $cmakeUrl $cmakeZip
    Write-Host 'Extracting CMake...'
    Expand-Archive -Path $cmakeZip -DestinationPath $toolsDir -Force

    # Find extracted mingw / winlibs folder (some archives extract directly to 'mingw64')
    $winlibsDir = Get-ChildItem -Path $toolsDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'mingw64\bin') } | Select-Object -First 1
    if (-not $winlibsDir) {
        # fallback: check tools\mingw64 directly
        if (Test-Path (Join-Path $toolsDir 'mingw64')) {
            $winlibsDir = Get-Item (Join-Path $toolsDir 'mingw64')
            $mingwBin = Join-Path $winlibsDir.FullName 'bin'
        } else {
            throw 'WinLibs (mingw64) directory not found after extraction'
        }
    } else {
        $mingwBin = Join-Path $winlibsDir.FullName 'mingw64\bin'
    }
    if (-not (Test-Path $mingwBin)) { throw "Cannot find Mingw bin at $mingwBin" }

    $cmakeDir = Get-ChildItem -Path $toolsDir -Directory | Where-Object { $_.Name -Match '^cmake' } | Select-Object -First 1
    if (-not $cmakeDir) { throw 'CMake directory not found after extraction' }
    $cmakeBin = Join-Path $cmakeDir.FullName 'bin'

    # Make sure plain 'g++.exe' and 'gcc.exe' exist in bin (some distributions use prefixed names)
    $gppCandidates = Get-ChildItem -Path $mingwBin -Filter '*g++.exe' -File | Select-Object -First 1
    $gccCandidates = Get-ChildItem -Path $mingwBin -Filter '*gcc.exe' -File | Where-Object { $_.Name -notmatch 'g\+\+' } | Select-Object -First 1
    if ($gppCandidates -and -not (Test-Path (Join-Path $mingwBin 'g++.exe'))) {
        Write-Host 'Creating g++.exe shim in mingw bin'
        Copy-Item $gppCandidates.FullName (Join-Path $mingwBin 'g++.exe') -Force
    }
    if ($gccCandidates -and -not (Test-Path (Join-Path $mingwBin 'gcc.exe'))) {
        Write-Host 'Creating gcc.exe shim in mingw bin'
        Copy-Item $gccCandidates.FullName (Join-Path $mingwBin 'gcc.exe') -Force
    }

    # Add to PATH for this session
    $env:Path = "$mingwBin;$cmakeBin;$env:Path"

    Write-Host "gcc: $(gcc --version | Select-Object -First 1)"
    Write-Host "cmake: $(cmake --version | Select-Object -First 1)"

    # Try to build using build.bat
    Push-Location $repoRoot
    Write-Host 'Running build.bat...'
    & "${repoRoot}\build.bat"
    Pop-Location

    Write-Host 'Toolchain install and build attempt finished.'
} catch {
    Write-Error "Error: $_"
    exit 1
}
