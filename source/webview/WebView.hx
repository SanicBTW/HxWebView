package webview;

// So this is what the WebView.hx class became now I guess
// Once I figure out how to properly import the webview.h file globally without redefinitions (LNK2005) I will properly rewrite it
// This should not be used when embedding as a widget since it could cause undefined behaviour.
// Since the implementation for each platform is different, WebViewHelper.cpp automatically handles this depending on the platform.
// Bro tf are these comments bruh :sob: :sob:

import cpp.Pointer;
import cpp.ConstCharStar;
import cpp.Void as CVoid;

// I learnt that a void pointer is a data type which acts like a dynamic and you need to cast it in need to retrieve the data 
typedef WindowPtr = Pointer<CVoid>;

// Holds the elements of a MAJOR.MINOR.PATCH version number.
typedef WebViewVersion = 
{
    // Major version.
    var major:Int;
    // Minor version.
    var minor:Int;
    // Patch version.
    var patch:Int;
}

// Holds the library's version information.
typedef WebViewInfo = 
{
    // The elements of the version number.
    var version:WebViewVersion;
    // SemVer 2.0.0 version number in MAJOR.MINOR.PATCH format.
    var version_number:String;
    // SemVer 2.0.0 pre-release labels prefixed with "-" if specified, otherwise
    // an empty string.
    var pre_release:String;
    // SemVer 2.0.0 build metadata prefixed with "+", otherwise an empty string.
    var build_metadata:String;
}

// Window size hints
enum abstract WebViewSizeHint(Int) to Int from Int
{
    var NONE = 0;
    var MIN = 1;
    var MAX = 2;
    var FIXED = 3;
}

// Native handle kind. The actual type depends on the backend.
// An integer enum for the cpp fix, check WebViewHelper.cpp.
// @since 0.11
enum abstract WebViewNativeHandleKind(Int) to Int from Int
{
    /**
     * Top-level window. GtkWindow pointer (GTK), NSWindow pointer (Cocoa) or HWND (Win32).
     */
    var WEBVIEW_NATIVE_HANDLE_KIND_UI_WINDOW = 0;

    /**
     * Browser widget. GtkWidget pointer (GTK), NSView pointer (Cocoa) or HWND (Win32).
     */
    var WEBVIEW_NATIVE_HANDLE_KIND_UI_WIDGET = 1;

    /**
     * Browser controller. WebKitWebView pointer (WebKitGTK), WKWebView pointer (Cocoa/WebKit) or
     * ICoreWebView2Controller pointer (Win32/WebView2).
     */
    var WEBVIEW_NATIVE_HANDLE_KIND_BROWSER_CONTROLLER = 2;
}

// Used in webview_dispatch
typedef DispatchFunc = (w:WindowPtr, arg:Dynamic)->Void;

// Used in webview_bind
typedef BindFunc = (seq:String, req:String, arg:Dynamic)->Void;

// Wrapper class for the externs
#if (!display && windows)
@:build(webview.Macros.copyDLLs())
#end
class WebView
{
    /// Window Properties
    private var handle:Null<WindowPtr> = null;
    private var x:Int = 0;
    private var y:Int = 0;
    private var width:Int = 0;
    private var height:Int = 0;
    private var decorated:Bool = true;
    private var topmost:Bool = false;
    private var shouldAllowDestroy:Bool = true; // Only used in Linux

    /// WEBVIEW

    /**
     * Creates a new webview instance.
     * 
     * Depending on the platform, a GtkWindow, NSWindow or HWND pointer can be
     * passed on the window argument. 
     * 
     * If the window handle is non-null, the webview 
     * widget is embedded into the given window, and the
     * caller is expected to assume responsibility for the window as well as
     * application lifecycle
     * 
     * Creation can fail for various reasons
     * such as when required runtime dependencies are missing or when window creation
     * fails.
     * 
     * Remarks:
     * - Win32: The function also accepts a pointer to HWND (Win32) in the window
     * parameter for backward compatibility.
     * - Win32/WebView2: CoInitializeEx should be called with
     * COINIT_APARTMENTTHREADED before attempting to call this function with an
     * existing window. Omitting this step may cause WebView2 initialization to fail.
     * 
     * @param debug If true, developer tools will be enabled (if the platform supports them).
     * @param window [Pointer to the native window handle] If a pointer is passed, then child webview will be embedded into the given parent window, otherwise a new window is created.
     */
    public function new(debug:Bool = false, ?window:WindowPtr)
    {
        handle = Externs.webview_create(debug ? 1 : 0, window);

        if (handle == null)
        {
            trace('Failed to create a WebView');
            return;
        }
    }

    /**
     * Destroys a webview and closes the native window.
     */
    public function destroy():Void
    {
        if (handle == null #if linux || !shouldAllowDestroy #end)
            return;

        Externs.webview_destroy(handle);
    }

    /**
     * Runs the main loop until it's terminated.
     * 
     * After this function exits you must destroy the webview.
     */
    public function run():Void
    {
        if (handle == null)
            return;

        Externs.webview_run(handle);
    }

    /**
     * Stops the main loop.
     * 
     * It is safe to call this function from another thread.
     */
    public function terminate():Void
    {
        if (handle == null)
            return;

        Externs.webview_terminate(handle);
    }

    /**
     * Posts a function to be executed on the main thread.
     * 
     * You normally do not need to call this function, unless you want to tweak the native window.
     */
    public function dispatch(fn:DispatchFunc, arg:Dynamic):Void
    {
        if (handle == null)
            return;

        Externs.webview_dispatch(handle, fn, arg);
    }

    /**
     * Returns the native handle of the window associated with the webview instance.
     * 
     * When using a GTK backend the pointer is a GtkWindow handle.
     * 
     * When using a Cocoa backend the pointer is a NSWindow handle.
     * 
     * When using a Win32 backend the pointer is a HWND handle.
     */
    public function getWindow():WindowPtr
    {
        if (handle == null)
            return null;

        return Externs.webview_get_window(handle);
    }

    /**
     * Returns the native handle of choice
     * 
     * @since 0.11
     */
    public function getNativeHandle(kind:WebViewNativeHandleKind):WindowPtr
    {
        if (handle == null)
            return null;

        return Externs.webview_get_native_handle(handle, kind);
    }

    /**
     * Updates the title of the native window.
     * 
     * Must be called from the UI thread.
     */
    public function setTitle(title:String):Void
    {
        if (handle == null)
            return;

        Externs.webview_set_title(handle, title);
    }

    /**
     * Updates the size of the native window.
     * 
     * See WebViewSizeHint enum.
     */
    public function setSize(width:Int, height:Int, hints:WebViewSizeHint):Void
    {
        if (handle == null || width <= 0 && height <= 0)
            return;

        this.width = width;
        this.height = height;

        Externs.webview_set_size(handle, width, height, hints);
    }

    /**
     * Navigates webview to the given URL.
     * 
     * URL may be a properly encoded data URI.
     * 
     * Example:
     * 
     * ```haxe
     * var webview:WebView = new WebView();
     * webview.navigate("https://github.com/webview/webview");
     * webview.navigate("data:text/html,%3Ch1%3EHello%3C%2Fh1%3E");
     * webview.navigate("data:text/html;base64,PGgxPkhlbGxvPC9oMT4=");
     * ```
     */
    public function navigate(url:String):Void
    {
        if (handle == null)
            return;

        Externs.webview_navigate(handle, url);
    }

    /**
     * Set webview HTML directly.
     * 
     * Example:
     * 
     * ```haxe
     * var webview:WebView = new WebView();
     * webview.setHTML("<h1>Hello</h1>");
     * ```
     */
    public function setHTML(html:String):Void
    {
        if (handle == null)
            return;

        Externs.webview_set_html(handle, html);
    }

    /**
     * Injects JavaScript code at the initialization of the new page.
     * 
     * Every time the webview will open a new page, this initialization code will be executed.
     * 
     * It is guaranteed that the code is executed before window.onload.
     */
    public function init(js:String):Void
    {
        if (handle == null)
            return;

        Externs.webview_init(handle, js);
    }

    /**
     * Evaluates arbitrary JavaScript code.
     * 
     * Evaluation happens asynchronously, also the result of the expression is ignored.
     * 
     * Use RPC bindings if you want to receive notifications about the results of the evaluation.
     */
    public function eval(js:String):Void
    {
        if (handle == null)
            return;

        Externs.webview_eval(handle, js);
    }

    /**
     * Binds a native Haxe callback so that it will appear under the given name as a global JavaScript function.
     * 
     * Internally it uses webview.init().
     * 
     * The callback receives a sequential request id, a request string and a user-provided argument pointer.
     * 
     * The request string is a JSON array of all the arguments passed to the JavaScript function.
     */
    public function bind(name:String, fn:BindFunc, arg:Dynamic):Void
    {
        if (handle == null)
            return;

        Externs.webview_bind(handle, name, fn, arg);
    }

    /**
     * Removes a native Haxe callback that was previously set by webview.bind
     */
    public function unbind(name:String):Void
    {
        if (handle == null)
            return;

        Externs.webview_unbind(handle, name);
    }

    /**
     * Responds to a binding call from the JavaScript side.
     * 
     * The ID/sequence number must match the value passed to the binding handler
     * in order to respond to the call and complete the promise on the JavaScript side.
     * 
     * A status of zero resolves the promise, and any other value rejects it.
     * 
     * The result must either be a valid JSON value or an empty string for the primitive JS value "undefined".
     */
    public function resolve(seq:String, status:Int, result:String):Void
    {
        if (handle == null)
            return;

        Externs.webview_return(handle, seq, status, result);
    }

    /**
     * Get the library's version information.
     * @since 0.10
     */
    public static function version():WebViewInfo
        return Externs.webview_version();

    /// WINDOW UTILS

    /**
     * Used to get the Main Window from the current process.
     * 
     * This behaves almost like webview.getWindow() if the WebView is a standalone Window.
     */
    public function getMainWindow():WindowPtr
    {
        return Externs.find_main_window();
    }

    /**
     * Used to get the WebView Window Position.
     * 
     * Win32 API and GTK API - Fully working
     * 
     * Cocoa API - Not Implemented
     */
    public function getWindowPosition():{x:Int, y:Int}
    {
        return Externs.get_window_position(handle);
    }

    /**
     * Used to set the WebView Window Position.
     * 
     * Win32 API and GTK API - Fully working (Windows pending DPI Awareness)
     * 
     * Cocoa API - Not Implemented
     */
    public function setWindowPosition(newX:Int, newY:Int):Void
    {
        Externs.set_window_position(handle, newX, newY);
    }

    /**
     * Used to set the WebView Window Decoration.
     * 
     * Win32 API and GTK API - Fully working 
     * 
     * Cocoa API - Not Implemented
     */
    public function setWindowDecoration(state:Bool):Void
    {
        decorated = state;
        Externs.set_window_decoration(handle, state);
    }

    /**
     * Used to set the WebView Window TopMost.
     * 
     * Win32 API and GTK API - Fully working
     * 
     * Cocoa API - Not Implemented
     */
    public function setWindowTopmost(state:Bool):Void
    {
        topmost = state;
        Externs.set_window_topmost(handle, state);
    }

    /**
     * Used to add a destroy signal and set the WebView Window internal destroyed flag.
     * 
     * Win32 API - Not needed
     * 
     * Gtk API - Fully working
     * 
     * Cocoa API - Not Implemented
     */
    public function addDestroySignal():Void
    {
        shouldAllowDestroy = false;
        Externs.add_destroy_signal(handle);
    }

    /**
     * Used to get if there are pending events.
     * 
     * Win32 API and GTK API - Fully working
     * 
     * Cocoa API - Not Implemented
     */
    public function eventsPending():Bool
    {
        return Externs.events_pending(handle);
    }

    /**
     * Used to run a Main Loop Iteration to process events and more.
     * 
     * State should be true if you want GTK+ to block if no events are pending. (Not taken into account on Win32)
     * 
     * This will run at 60FPS on Win32 and around 12FPS on GTK, pending fix for Linux.
     * 
     * Win32 API and GTK API - Fully working
     * 
     * Cocoa API - Not Implemented
     */
    public function process(state:Bool = false):Void
    {
        Externs.run_main_iteration(state);
    }

    /**
     * Used to check if the WebView Window is still open.
     * 
     * It uses the same variable behind the scenes, it just the checks that are different for each platform.
     */
    public function isOpen():Bool
    {
        return Externs.is_open();
    }
}

/// RAW EXTERNS

@:keep
@:buildXml("<include name=\"${haxelib:HxWebView}/include.xml\"/>")
@:include("internal/imports.h")
private extern class Externs
{
    /// WEBVIEW.H EXTERNS

    @:native('webview_create')
    public static function webview_create(debug:Int, ?window:WindowPtr):WindowPtr;

    @:native('webview_destroy')
    public static function webview_destroy(w:WindowPtr):Void;

    @:native('webview_run')
    public static function webview_run(w:WindowPtr):Void;

    @:native('webview_terminate')
    public static function webview_terminate(w:WindowPtr):Void;

    // Can be found on WebViewHelper.cpp
    @:native('hx_webview_dispatch')
    public static function webview_dispatch(w:WindowPtr, fn:DispatchFunc, arg:Dynamic):Void;

    @:native('webview_get_window')
    public static function webview_get_window(w:WindowPtr):WindowPtr;

    // Can be found on WebViewHelper.cpp
    // Returns a native handle of choice.
    // @since 0.11
    @:native('hx_get_native_handle')
    public static function webview_get_native_handle(w:WindowPtr, kind:WebViewNativeHandleKind):WindowPtr;

    @:native('webview_set_title')
    public static function webview_set_title(w:WindowPtr, title:ConstCharStar):Void;

    // Can be found on WebViewHelper.cpp
    @:native('hx_set_size')
    public static function webview_set_size(w:WindowPtr, width:Int, height:Int, hints:WebViewSizeHint):Void;

    @:native('webview_navigate')
    public static function webview_navigate(w:WindowPtr, url:ConstCharStar):Void;

    @:native('webview_set_html')
    public static function webview_set_html(w:WindowPtr, html:ConstCharStar):Void;

    @:native('webview_init')
    public static function webview_init(w:WindowPtr, js:ConstCharStar):Void;

    @:native('webview_eval')
    public static function webview_eval(w:WindowPtr, js:ConstCharStar):Void;

    // Can be found on WebViewHelper.cpp
    @:native('hx_webview_bind')
    public static function webview_bind(w:WindowPtr, name:ConstCharStar, fn:BindFunc, arg:Dynamic):Void;

    @:native('webview_unbind')
    public static function webview_unbind(w:WindowPtr, name:ConstCharStar):Void;

    @:native('webview_return')
    public static function webview_return(w:WindowPtr, seq:ConstCharStar, status:Int, result:ConstCharStar):Void;

    // Can be found on WebViewHelper.cpp
    // Get the library's version information.
    // @since 0.10
    @:native('hx_webview_version')
    public static function webview_version():WebViewInfo;

    /// END OF WEBVIEW.H EXTERNS

    /// WINDOWUTILS.H

    @:native("get_window_position")
    public static function get_window_position(w:WindowPtr):{x:Int, y:Int};

    @:native('set_window_position')
    public static function set_window_position(w:WindowPtr, newX:Int, newY:Int):Void;

    @:native("set_window_decoration")
    public static function set_window_decoration(w:WindowPtr, state:Bool):Void;

    @:native("set_window_topmost")
    public static function set_window_topmost(w:WindowPtr, state:Bool):Void;

    @:native("add_destroy_signal")
    public static function add_destroy_signal(w:WindowPtr):Void;

    @:native("events_pending")
    public static function events_pending(w:WindowPtr):Bool;

    @:native("run_main_iteration")
    public static function run_main_iteration(state:Bool):Void;

    @:native("is_open")
    public static function is_open():Bool;

    // Used to get the Main Window from the process, this behaves almost like webview_get_window if the WebView is a standalone Window
    @:native('find_main_window')
    public static function find_main_window():WindowPtr;

    /// END OF WINDOWUTILS.H EXTERNS
}