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
    SetWindowPos((HWND)webview_get_window(w), NULL, newX, newY, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
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

void add_destroy_signal(webview_t w)
{
    return;
}

// FIRST TRY BABY WOOHOO - nvm
// ok so it really works except when trying to run without another loop on top so uhhh i gotta look into it - fixed it by removing the other flag
// but is slow af when trying to dispatch binds tf, ill see if i can mess around with GetQueueStatus
// get queue status didnt work out but now it works, had to put a null ptr or smth null in the hwnd since its optional
// now gets all the queue messages n shit, cool shit
bool events_pending(webview_t w)
{
    MSG msg;
    return PeekMessageW(&msg, nullptr, 0, 0, PM_NOREMOVE) != 0;
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
// https://docs.gtk.org/gtk3/index.html?q=gtk_window_set_
// https://docs.gtk.org/gtk3/index.html?q=gtk_window_get_
// https://docs.gtk.org/gtk3/index.html?q=gtk_main

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

void add_destroy_signal(webview_t w) // Should be called to add the signal listener for window destroy, thus being able to check if the window is destroyed
{
    g_signal_connect(GTK_WINDOW(webview_get_window(w)), "delete-event", G_CALLBACK(+[](GtkWidget *, gpointer arg)
    {
        is_destroyed = true;
        return FALSE;
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