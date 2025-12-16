# GUI
A C++ application combining a console menu with a GUI progress bar. It simulates a cancellable 0–100% process, updates the GUI in real time, handles cancellation via the GUI, and reports results to the console. The GUI behaves as a dependent child window, visible only when the console is active.

## Building the Project

### Prerequisites
- Windows OS
- CMake
- Visual Studio with C++ compiler (MSVC) or MinGW with g++

### Using CMake
1. Install CMake.
2. Run: `cmake -S . -B build`
3. Run: `cmake --build build --config Release`
4. The executable will be in `build/Release/gui.exe`

### Using MSVC (Visual Studio)
1. Open the Developer Command Prompt.
2. Navigate to the project root.
3. Compile with: `cl /MT src\main.cpp src\gui.cpp user32.lib comctl32.lib /Fe:build\gui.exe`

### Using MinGW
1. Install MinGW with g++.
2. Run: `g++ -o build/gui.exe src/main.cpp src/gui.cpp -static -lcomctl32 -lgdi32 -luser32`

Note: Do NOT use `-mwindows` for this project since the console must remain visible for the menu and status messages; `-mwindows` hides the console window.

## Automated installer (Windows)

If you don't have a compiler or CMake installed, there's a convenience script `scripts\install-toolchain.ps1` that downloads a portable MinGW (WinLibs) and CMake into `tools/`, adds them to PATH for the current session, and attempts to build the project.

Run from PowerShell (from repository root):
```powershell
.\scripts\install-toolchain.ps1
```

## Running
Execute `build/gui.exe` (or `build/Release/gui.exe`) from the command prompt.

## Automated Smoke Test
A small automated smoke test exists to verify build and run behavior non-interactively:

```powershell
# Builds (using tools/mingw64 if present) and runs the executable with GUI_AUTO_START=1
.\scripts\auto_test.ps1
```

## Exit Behavior
When the process completes or is cancelled the console prints the final status, waits 2 seconds for the user to read it, then the application exits (no menu is shown again).

## Dependencies
- Win32 API (built-in on Windows)
- Common Controls (comctl32.lib)

## GUI Framework
Win32 API for native Windows GUI.
