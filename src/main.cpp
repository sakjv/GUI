#include <iostream>
#include <thread>
#include <atomic>
#include <windows.h>
#include "gui.h"

int main() {
    HWND consoleHwnd = GetConsoleWindow();
    while (true) {
        std::cout << "1. Start Process\n2. Exit\n";
        int choice;
        std::cin >> choice;
        if (choice == 2) break;
        if (choice == 1) {
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
        }
    }
    return 0;
}