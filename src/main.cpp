#include <iostream>
#include <thread>
#include <atomic>
#include <cstring>
#include <windows.h>
#include "gui.h"

int main() {
    HWND consoleHwnd = GetConsoleWindow();
    const char* autoStart = getenv("GUI_AUTO_START");
    while (true) {
        // If GUI_AUTO_START is set, automatically start the process once for testing.
        if (autoStart && strcmp(autoStart, "1") == 0) {
            std::cout << "Auto-starting process...\n";
        } else {
            std::cout << "1. Start Process\n2. Exit\n";
            int choice;
            std::cin >> choice;
            if (choice == 2) break;
            if (choice != 1) continue;
        }
        if (true) {
            std::atomic<bool> cancelled(false);
            createGUI(consoleHwnd, cancelled);
            std::thread processThread([&]() {
                for (int i = 0; i <= 100; ++i) {
                    if (cancelled) break;
                    updateProgress(i);
                    Sleep(100);
                }
                closeWindow();
                if (cancelled) {
                    std::cout << "Process cancelled\n";
                } else {
                    std::cout << "Process completed\n";
                }
            });
            processThread.join();
            // After completion or cancellation, update status (printed by the worker),
            // wait briefly so the user can read it, then exit the application.
            Sleep(2000);
            break;
        }
    }
    return 0;
}