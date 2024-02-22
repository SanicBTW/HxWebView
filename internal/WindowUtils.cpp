#if defined(_WIN32)
#include <windows.h>
#include <processthreadsapi.h>
#endif

#if defined(HX_LINUX)
#include <gtk/gtk.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#endif

// File to add Window Utilities for controlling the WebView Window

bool is_destroyed = false;

#if defined(_WIN32)
// Get the Parent/Main Window from current process, origin https://stackoverflow.com/a/21767578
struct HANDLE_DATA
{
    DWORD process_id;
    HWND window_handle;
};

HWND find_main_window();
BOOL CALLBACK enum_windows_callback(HWND handle, LPARAM lParam);
BOOL is_main_window(HWND handle);

HWND find_main_window()
{
    HANDLE_DATA data;
    data.process_id = GetCurrentProcessId();
    data.window_handle = 0;
    EnumWindows(enum_windows_callback, (LPARAM)&data);
    return data.window_handle;
}

BOOL CALLBACK enum_windows_callback(HWND handle, LPARAM lParam)
{
    HANDLE_DATA& data = *(HANDLE_DATA*)lParam;
    DWORD process_id;
    GetWindowThreadProcessId(handle, &process_id);
    if (data.process_id != process_id || !is_main_window(handle))
        return TRUE;
    data.window_handle = handle;
    return FALSE;
}

BOOL is_main_window(HWND handle)
{
    return GetWindow(handle, GW_OWNER) == (HWND)0 && IsWindowVisible(handle);
}

// Make DPI Aware
Dynamic get_window_position(webview_t w)
{
    RECT rect;
    BOOL res = GetWindowRect((HWND)webview_get_window(w), &rect);
    if (res == 0)
    {
        rect = {
            0, // left
            0, // top
            0, // right
            0 // bottom
        };
    }

    hx::Anon windowPos = hx::Anon_obj::Create();

        windowPos->Add(HX_CSTRING("x"), (int)rect.left);
        windowPos->Add(HX_CSTRING("y"), (int)rect.top);

    return windowPos;
}

void set_window_position(webview_t w, int newX, int newY)
{
    HWND wPtr = (HWND)webview_get_window(w);

    RECT rect;
    BOOL res = GetClientRect(wPtr, &rect);
    if (res == 0)
    {
        // This is kind of dumb ngl
        rect = {
            0, // left
            0, // top
            0, // right
            0 // bottom
        };
    }
    long width = rect.right - rect.left;
    long height = rect.bottom - rect.top;
    MoveWindow(wPtr, newX, newY, width, height, FALSE);
}

// https://stackoverflow.com/a/2400467
// Spent almost an hour or smth to make this work properly without any more arguments
void set_window_decoration(webview_t w, bool state)
{
    HWND wPtr = (HWND)webview_get_window(w);

    LONG lStyle = GetWindowLong(wPtr, GWL_STYLE);

    if (state)
    {
        lStyle |= (WS_CAPTION | WS_THICKFRAME | WS_SYSMENU);
    }
    else
    {
        lStyle &= ~(WS_CAPTION | WS_THICKFRAME | WS_SYSMENU);
    }

    SetWindowLong(wPtr, GWL_STYLE, lStyle);

    SetWindowPos(wPtr, NULL, 0,0,0,0, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
}

void set_window_topmost(webview_t w, bool state)
{
    SetWindowPos((HWND)webview_get_window(w), (state) ? HWND_TOPMOST : HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
}

// Sadly on Windows none of the expected behaviour from Linux occurs, in order to hide a window from the taskbar
// Is to make it owned by the parent window n some more stuff
// It might get deleted on both targets since it doesn't behave as expected
// https://stackoverflow.com/questions/30933219/hide-window-from-taskbar-without-using-ws-ex-toolwindow?rq=3
// https://stackoverflow.com/questions/7219063/win32-how-to-hide-3rd-party-windows-in-taskbar-by-hwnd
// https://stackoverflow.com/questions/42554842/hide-show-the-application-icon-of-the-windows-taskbar-labview-winapi
void set_window_taskbar_hint(webview_t w, bool state)
{
    HWND wPtr = (HWND)webview_get_window(w);

    LONG lExStyle = GetWindowLong(wPtr, GWL_EXSTYLE);

    if (state)
    {
        lExStyle |= (WS_EX_APPWINDOW | WS_EX_TOOLWINDOW);
        SetWindowLongPtrW(wPtr, GWLP_HWNDPARENT, 0);
    }
    else
    {
        lExStyle &= ~(WS_EX_APPWINDOW | WS_EX_TOOLWINDOW);
        SetWindowLongPtrW(wPtr, GWLP_HWNDPARENT, reinterpret_cast<LONG_PTR>(find_main_window()));
    }

    SetWindowLong(wPtr, GWL_EXSTYLE, lExStyle);
}

void add_destroy_signal(webview_t w)
{
    return;
}

// FIRST TRY BABY WOOHOO - nvm - ok so it really works except when trying to run without another loop on top so uhhh i gotta look into it
bool events_pending(webview_t w)
{
    MSG msg;
    return (bool)PeekMessageW(&msg, (HWND)webview_get_window(w), 0, 0, PM_NOREMOVE | PM_QS_POSTMESSAGE);
}

void run_main_iteration(bool state)
{
    MSG msg;
    BOOL res = GetMessageW(&msg, nullptr, 0, 0);
    if (res > 0)
    {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }
    else
    {
        is_destroyed = true;
    }
}
#endif

#if defined(HX_LINUX)
Dynamic find_main_window(); //TODO

// https://docs.gtk.org/gtk3/index.html?q=gtk_window_set_
// https://docs.gtk.org/gtk3/index.html?q=gtk_window_get_
// https://docs.gtk.org/gtk3/index.html?q=gtk_main

Dynamic find_main_window()
{
    return 0;
}

Dynamic get_window_position(webview_t w) // https://docs.gtk.org/gtk3/method.Window.get_position.html
{
    gint wX, wY;
    gtk_window_get_position(GTK_WINDOW(webview_get_window(w)), &wX, &wY);

    hx::Anon windowPos = hx::Anon_obj::Create();

        windowPos->Add(HX_CSTRING("x"), (int)wX);
        windowPos->Add(HX_CSTRING("y"), (int)wY);

    return windowPos;
}

void set_window_position(webview_t w, int newX, int newY) // https://docs.gtk.org/gtk3/method.Window.move.html there is https://docs.gtk.org/gtk3/method.Window.set_position.html but seems fixed positions
{
    gtk_window_move(GTK_WINDOW(webview_get_window(w)), (gint)newX, (gint)newY);
}

void set_window_decoration(webview_t w, bool state) // https://docs.gtk.org/gtk3/method.Window.set_decorated.html
{
    gtk_window_set_decorated(GTK_WINDOW(webview_get_window(w)), (gboolean)state);
}

void set_window_topmost(webview_t w, bool state) // https://docs.gtk.org/gtk3/method.Window.set_keep_above.html called topmost for standards
{
    gtk_window_set_keep_above(GTK_WINDOW(webview_get_window(w)), (gboolean)state);
}

void set_window_taskbar_hint(webview_t w, bool state) // https://docs.gtk.org/gtk3/method.Window.set_skip_taskbar_hint.html
{
    gtk_window_set_skip_taskbar_hint(GTK_WINDOW(webview_get_window(w)), (gboolean)state);
}

void add_destroy_signal(webview_t w) // Should be called to add the signal listener for window destroy, thus being able to check if the window is destroyed
{
    g_signal_connect(GTK_WINDOW(webview_get_window(w)), "delete_event", G_CALLBACK(+[](GtkWidget *, gpointer arg)
    {
        is_destroyed = true;
    }), NULL);
}

// webview_t isn't used in here
bool events_pending(webview_t w) // https://docs.gtk.org/gtk3/func.events_pending.html
{
    return (bool)gtk_events_pending();
}

void run_main_iteration(bool state) // https://docs.gtk.org/gtk3/func.main_iteration_do.html
{
    gtk_main_iteration_do((gboolean)state);
}
#endif

bool is_open()
{
    // this will return false if the window is not destroyed, so we return true to indicate that its still open
    return !is_destroyed;
}