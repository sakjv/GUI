Local build & test guide

This short guide explains how to quickly build and test local changes to the GUI project.

Prerequisites
- Windows
- PowerShell
- A C++ compiler (MSVC or MinGW)

If you don't have a compiler, run:

```powershell
.\scripts\install-toolchain.ps1
```

Quick build

Using bundled MinGW (recommended / tested) ✅

```powershell
# Make the bundled MinGW first on PATH for the session (PowerShell)
$env:Path = "$PWD\tools\mingw64\bin;$env:Path"

# Full rebuild using the bundled g++ (explicit path is recommended to avoid PATH issues)
& "$PWD\tools\mingw64\bin\g++.exe" -o build\gui.exe src\main.cpp src\gui.cpp -I include -static -lcomctl32 -lgdi32 -luser32

# Or simply run the repository build script (it will detect g++ or cl):
.\build.bat
```

Using MSVC (`cl`) (optional)

```powershell
# Open the 'x64 Native Tools Command Prompt for VS' or 'Developer Command Prompt'
# Then run (example):
cl /MT src\main.cpp src\gui.cpp user32.lib comctl32.lib /Fe:build\gui.exe

# Or use the included VS Code task:
# - Run 'Tasks: Run Task' -> 'Build GUI Project'
```

Quick checks

```powershell
# Verify g++ (bundled):
& "$PWD\tools\mingw64\bin\g++.exe" --version

# Verify cl (MSVC) is on PATH:
where cl
```

Stop running instances (exe lock) if necessary:

```powershell
taskkill /F /IM gui.exe /T
```

Run interactively (press `1` to start):

```powershell
.\build\gui.exe
```

Smoke check (non-interactive):

```powershell
$env:GUI_AUTO_START = '1'
.\build\gui.exe
# or run the automated verifier:
.\scripts\auto_test.ps1
```

Interactive helper:

```powershell
.\test\test_gui.ps1
```

Notes
- Tested toolchain: the **bundled MinGW** (`tools/mingw64`) builds successfully in this repo; MSVC `cl` is not on PATH by default on this system. If you prefer MSVC, open the **Developer Command Prompt** so `cl` is available.
- Keep console visible (do not use `-mwindows`) to be able to interact with the menu.
- Use `taskkill` if the executable is locked while rebuilding.

Want a fast incremental build or a file-watcher to rebuild on changes? I can add a `watch` script (PowerShell) that rebuilds only modified files and reruns the smoke test. Let me know if you want that.
