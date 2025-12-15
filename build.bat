@echo off
if not exist build mkdir build
cl /MT src\main.cpp src\gui.cpp user32.lib comctl32.lib /Fe:build\gui.exe
echo Build complete. Run build\gui.exe