package webview;

// Class made to wrap all the Window Utils made for controlling the WebView independant Window
// This should not be used when embedding as a widget since it could cause undefined behaviour.

// Since the implementation for each platform is different, WebViewHelper.cpp automatically handles this depending on the platform.
// Bro tf are these comments bruh :sob: :sob:

import webview.WebView;

typedef WindowPosition =
{
    var x:Int;
    var y:Int;
}

class WindowUtils
{
    /**
     * Used to get the Main Window from the current process.
     * 
     * This behaves almost like webview.getWindow() if the WebView is a standalone Window.
     */
    public static function getMainWindow():WindowPtr
    {
        return Externs.find_main_window();
    }

    /**
     * Used to get the WebView Window Position.
     * 
     * Win32 API - Not Implemented
     * 
     * Gtk API - Implemented fully working
     * 
     * Cocoa API - Not Implemented (Not maintained by me)
     */
    public static function getWindowPosition(w:WebView):WindowPosition
    {
        return Externs.get_window_position(w.handle);
    }

    /**
     * Used to set the WebView Window Position.
     * 
     * Win32 API - Not Implemented
     * 
     * Gtk API - Implemented fully working
     * 
     * Cocoa API - Not Implemented (Not maintained by me)
     */
    public static function setWindowPosition(w:WebView, newX:Int, newY:Int):Void
    {
        Externs.set_window_position(w.handle, newX, newY);
    }

    /**
     * Used to set the WebView Window Decoration.
     * 
     * Win32 API - Not Implemented
     * 
     * Gtk API - Implemented fully working
     * 
     * Cocoa API - Not Implemented (Not maintained by me)
     */
    public static function setWindowDecoration(w:WebView, state:Bool):Void
    {
        Externs.set_window_decoration(w.handle, state);
    }

    /**
     * Used to set the WebView Window TopMost.
     * 
     * Win32 API - Not Implemented
     * 
     * Gtk API - Implemented fully working
     * 
     * Cocoa API - Not Implemented (Not maintained by me)
     */
    public static function setWindowTopmost(w:WebView, state:Bool):Void
    {
        Externs.set_window_topmost(w.handle, state);
    }

    /**
     * Used to set the WebView Window Taskbar Visibility.
     * 
     * Win32 API - Not Implemented
     * 
     * Gtk API - Implemented fully working
     * 
     * Cocoa API - Not Implemented (Not maintained by me)
     */
    public static function setWindowTaskbarHint(w:WebView, state:Bool):Void
    {
        Externs.set_window_taskbar_hint(w.handle, state);
    }

    /**
     * Used to add a destroy signal and set the WebView Window internal destroyed flag.
     * 
     * Win32 API - Not Implemented
     * 
     * Gtk API - Implemented fully working
     * 
     * Cocoa API - Not Implemented (Not maintained by me)
     */
    public static function addDestroySignal(w:WebView):Void
    {
        Externs.add_destroy_signal(w.handle);
    }

    /**
     * Used to get if there are pending events.
     * 
     * Win32 API - Not Implemented
     * 
     * Gtk API - Implemented fully working
     * 
     * Cocoa API - Not Implemented (Not maintained by me)
     */
    public static function eventsPending(w:WebView):Bool
    {
        return Externs.events_pending();
    }

    /**
     * Used to run a Main Loop Iteration to process events and more.
     * 
     * State should be true if you want GTK+ to block if no events are pending.
     * 
     * Win32 API - Not Implemented
     * 
     * Gtk API - Implemented fully working
     * 
     * Cocoa API - Not Implemented (Not maintained by me)
     */
    public static function process(w:WebView, state:Bool = false):Void
    {
        Externs.run_main_iteration(state);
    }

    /**
     * Used to check if the WebView Window is still open.
     * 
     * State should be true if you want GTK+ to block if no events are pending.
     * 
     * Win32 API - Not Implemented
     * 
     * Gtk API - Implemented fully working
     * 
     * Cocoa API - Not Implemented (Not maintained by me)
     */
    public static function isOpen(w:WebView):Bool
    {
        return Externs.is_open();
    }
}

@:keep
@:include('internal/WindowUtils.cpp')
private extern class Externs
{
    // Used to retrieve the Window Position
    @:native("get_window_position")
    public static function get_window_position(w:WindowPtr):WindowPosition;

    // Used to set the Window Position
    @:native('set_window_position')
    public static function set_window_position(w:WindowPtr, newX:Int, newY:Int):Void;

    // Used to set the Window Decoration
    @:native("set_window_decoration")
    public static function set_window_decoration(w:WindowPtr, state:Bool):Void;

    // Used to set the Window as TopMost (Keep the Window on the top of all applications)
    @:native("set_window_topmost")
    public static function set_window_topmost(w:WindowPtr, state:Bool):Void;

    // Used to set the Window Taskbar Visibility
    @:native("set_window_taskbar_hint")
    public static function set_window_taskbar_hint(w:WindowPtr, state:Bool):Void;

    @:native("add_destroy_signal")
    public static function add_destroy_signal(w:WindowPtr):Void;

    @:native("events_pending")
    public static function events_pending():Bool;

    @:native("run_main_iteration")
    public static function run_main_iteration(state:Bool):Void;

    @:native("is_open")
    public static function is_open():Bool;

    // Used to get the Main Window from the process, this behaves almost like webview_get_window if the WebView is a standalone Window
    @:native('find_main_window')
    public static function find_main_window():WindowPtr;
}