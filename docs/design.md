# Design Document for GUI Progress Bar Controlled by Console

## Requirements

The application must provide a console interface with a menu to start a process or exit. Upon starting the process, a GUI window appears showing a progress bar from 0% to 100%, with a cancel button. The progress simulates a task over time and can be cancelled via the GUI. The GUI window behaves as a dependent window of the console, appearing above it when the console is active but not staying on top globally. Results are reported back to the console.

## Architecture

The application is structured as a single executable with the following components:

- **Console Interface**: Handles user input for menu selection.
- **Process Simulation**: Runs in a separate thread to simulate progress updates.
- **GUI Window**: Created in a separate thread, displays progress bar and cancel button, linked as a child to the console window.
- **Inter-thread Communication**: Uses atomic variables for cancellation flag and Windows messages for progress updates.

## Key Components and Responsibilities

- **main.cpp**: Entry point, manages console menu, launches threads for process and GUI.
- **gui.h/gui.cpp**: Defines GUI creation, progress updates (`updateProgress`), window management (`closeWindow`), and cancellation handling (`isCancelled`).
- **Process Thread**: Simulates progress by updating the progress bar at intervals, checks for cancellation.
- **GUI Thread**: Creates and manages the GUI window, processes messages, handles cancel button.

## Technologies, Frameworks, or Libraries

- **C++ Standard Library**: For threading (std::thread), atomic operations (std::atomic), and I/O (iostream).
- **Win32 API**: For GUI creation (windows, controls), window management (SetParent for child relationship), and message handling.
- **Common Controls Library (comctl32)**: For the progress bar control.

These were chosen because Win32 API is the native Windows GUI framework, ensuring no external dependencies and direct control over window behavior. The standard library provides cross-platform threading support, though the GUI is Windows-specific.

## Cross-Platform Compatibility

The code is not cross-platform due to reliance on Win32 API for GUI and console window handling. It is designed specifically for Windows.