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
2. Run: `g++ -o build/gui.exe src/main.cpp src/gui.cpp -mwindows -static -lcomctl32 -lgdi32 -luser32`

## Running
Execute `build/gui.exe` (or `build/Release/gui.exe`) from the command prompt.

## Dependencies
- Win32 API (built-in on Windows)
- Common Controls (comctl32.lib)

## GUI Framework
Win32 API for native Windows GUI.
