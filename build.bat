@echo off
REM Auto-detect compiler and build the project
where cl >nul 2>&1
if %ERRORLEVEL%==0 (
  echo Using MSVC (cl)...
  if not exist build mkdir build
  cl /MT src\main.cpp src\gui.cpp user32.lib comctl32.lib /Fe:build\gui.exe
  exit /b %ERRORLEVEL%
)
where g++ >nul 2>&1
if %ERRORLEVEL%==0 (
  echo Using MinGW (g++)...
  if not exist build mkdir build
  g++ -o build\gui.exe src\main.cpp src\gui.cpp -I include -static -lcomctl32 -lgdi32 -luser32
  exit /b %ERRORLEVEL%
)
echo No supported C++ compiler found on PATH (cl or g++).
echo Install Visual Studio Build Tools (cl) or MinGW (g++) and run this script from a developer shell.
exit /b 1
