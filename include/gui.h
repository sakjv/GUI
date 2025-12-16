#ifndef GUI_H
#define GUI_H

#include <atomic>
#include <windows.h>

void createGUI(HWND parent, std::atomic<bool>& cancelled);
void updateProgress(int percent);
void closeWindow();

// Returns true if the GUI Cancel button was pressed
bool isCancelled();

#endif