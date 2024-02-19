#include <hxcpp.h>
#include <hxString.h>
#include <string>
#include "./vendor/webview.h"

#if defined(_WIN32)
#include <windef.h>
#include <winuser.h>
#include <processthreadsapi.h>
#endif

#if defined(HX_LINUX)
#include <gtk/gtk.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#endif

// File to add Window Utilities for controlling the WebView Window

// Get the Parent/Main Window from current process, origin https://stackoverflow.com/a/21767578
#if defined(_WIN32)
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
#endif

#if defined(HX_LINUX)
Dynamic find_main_window(); //TODO

// https://docs.gtk.org/gtk3/index.html?q=gtk_window_set_
// https://docs.gtk.org/gtk3/index.html?q=gtk_window_get_

Dynamic get_window_position(webview_t w); // https://docs.gtk.org/gtk3/method.Window.get_position.html
void set_window_position(webview_t w, int newX, int newY); // https://docs.gtk.org/gtk3/method.Window.move.html there is https://docs.gtk.org/gtk3/method.Window.set_position.html but seems fixed positions
void set_window_decoration(webview_t w, bool state); // https://docs.gtk.org/gtk3/method.Window.set_decorated.html
void set_window_topmost(webview_t w, bool state); // https://docs.gtk.org/gtk3/method.Window.set_keep_above.html called topmost for standards
void set_window_taskbar_hint(webview_t w, bool state); // https://docs.gtk.org/gtk3/method.Window.set_skip_taskbar_hint.html

Dynamic find_main_window()
{
    return 0;
}

Dynamic get_window_position(webview_t w)
{
    gint wX, wY;
    gtk_window_get_position(GTK_WINDOW(webview_get_window(w)), &wX, &wY);

    hx::Anon windowPos = hx::Anon_obj::Create();

        windowPos->Add(HX_CSTRING("x"), (int)wX);
        windowPos->Add(HX_CSTRING("y"), (int)wY);

    return windowPos;
}

void set_window_position(webview_t w, int newX, int newY)
{
    gtk_window_move(GTK_WINDOW(webview_get_window(w)), (gint)newX, (gint)newY);
}

void set_window_decoration(webview_t w, bool state)
{
    gtk_window_set_decorated(GTK_WINDOW(webview_get_window(w)), (gboolean)state);
}

void set_window_topmost(webview_t w, bool state)
{
    gtk_window_set_keep_above(GTK_WINDOW(webview_get_window(w)), (gboolean)state);
}

void set_window_taskbar_hint(webview_t w, bool state)
{
    gtk_window_set_skip_taskbar_hint(GTK_WINDOW(webview_get_window(w)), (gboolean)state);
}
#endif