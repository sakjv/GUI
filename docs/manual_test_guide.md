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

```powershell
# Make MinGW first on PATH for the session (optional)
$env:Path = "$PWD\tools\mingw64\bin;$env:Path"

# Full rebuild (MinGW g++)
g++ -o build/gui.exe src/main.cpp src/gui.cpp -I include -static -lcomctl32 -lgdi32 -luser32
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
- Keep console visible (do not use `-mwindows`) to be able to interact with the menu.
- Use `taskkill` if the executable is locked while rebuilding.

Want a fast incremental build or a file-watcher to rebuild on changes? I can add a `watch` script (PowerShell) that rebuilds only modified files and reruns the smoke test. Let me know if you want that.
