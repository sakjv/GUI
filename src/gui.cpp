#include "gui.h"
#include <commctrl.h>
#include <thread>

HWND progressBar, cancelButton, guiWindow;
std::atomic<bool>* cancelledPtr;

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case WM_CREATE:
            cancelledPtr = (std::atomic<bool>*)((CREATESTRUCT*)lParam)->lpCreateParams;
            progressBar = CreateWindowEx(0, PROGRESS_CLASS, NULL, WS_CHILD | WS_VISIBLE,
                                         50, 50, 200, 20, hwnd, NULL, GetModuleHandle(NULL), NULL);
            cancelButton = CreateWindow("BUTTON", "Cancel", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                                        100, 100, 80, 30, hwnd, (HMENU)1, GetModuleHandle(NULL), NULL);
            SendMessage(progressBar, PBM_SETRANGE, 0, MAKELPARAM(0, 100));
            break;
        case WM_COMMAND:
            if (LOWORD(wParam) == 1) {
                *cancelledPtr = true;
                PostMessage(hwnd, WM_CLOSE, 0, 0);
            }
            break;
        case WM_CLOSE:
            DestroyWindow(hwnd);
            break;
        case WM_DESTROY:
            PostQuitMessage(0);
            break;
        default:
            return DefWindowProc(hwnd, msg, wParam, lParam);
    }
    return 0;
}

void guiThreadFunc(HWND parent, std::atomic<bool>& cancelled) {
    WNDCLASS wc = {0};
    wc.lpfnWndProc = WndProc;
    wc.hInstance = GetModuleHandle(NULL);
    wc.lpszClassName = "ProgressWindow";
    RegisterClass(&wc);

    // Create as an owned top-level window by passing `parent` as the owner (hWndParent).
    guiWindow = CreateWindowEx(0, "ProgressWindow", "Progress", WS_OVERLAPPEDWINDOW,
                               CW_USEDEFAULT, CW_USEDEFAULT, 300, 200, parent, NULL, GetModuleHandle(NULL), &cancelled);
    ShowWindow(guiWindow, SW_SHOWNORMAL);
    // Ensure the GUI window appears above the console window: briefly make it topmost
    // then remove topmost so it is not permanently always-on-top.
    SetWindowPos(guiWindow, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
    SetWindowPos(guiWindow, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
    UpdateWindow(guiWindow);

    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
}

void createGUI(HWND parent, std::atomic<bool>& cancelled) {
    InitCommonControls();
    std::thread guiThread(guiThreadFunc, parent, std::ref(cancelled));
    guiThread.detach();
}

void updateProgress(int percent) {
    if (progressBar) {
        SendMessage(progressBar, PBM_SETPOS, percent, 0);
    }
}

void closeWindow() {
    if (guiWindow) {
        PostMessage(guiWindow, WM_CLOSE, 0, 0);
    }
}

bool isCancelled() {
    if (cancelledPtr) return *cancelledPtr;
    return false;
}