package webview;

import webview.internal.WVExterns;
import cpp.Pointer;
import cpp.Void as CVoid;

// Wrapper class for the externs
@:allow(webview.WindowUtils)
class WebView
{
    private var handle:Null<WindowPtr> = null;

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
        handle = WVExterns.webview_create(debug ? 1 : 0, window);

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
        if (handle == null)
            return;

        WVExterns.webview_destroy(handle);
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

        WVExterns.webview_run(handle);
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

        WVExterns.webview_terminate(handle);
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

        WVExterns.webview_dispatch(handle, fn, arg);
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

        return WVExterns.webview_get_window(handle);
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

        return WVExterns.webview_get_native_handle(handle, cast kind);
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

        WVExterns.webview_set_title(handle, title);
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

        WVExterns.webview_set_size(handle, width, height, hints);
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

        WVExterns.webview_navigate(handle, url);
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

        WVExterns.webview_set_html(handle, html);
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

        WVExterns.webview_init(handle, js);
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

        WVExterns.webview_eval(handle, js);
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

        WVExterns.webview_bind(handle, name, fn, arg);
    }

    /**
     * Removes a native Haxe callback that was previously set by webview.bind
     */
    public function unbind(name:String):Void
    {
        if (handle == null)
            return;

        WVExterns.webview_unbind(handle, name);
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

        WVExterns.webview_return(handle, seq, status, result);
    }

    /**
     * Get the library's version information.
     * @since 0.10
     */
    public static function version():WebViewInfo
        return WVExterns.webview_version();
}

// Moved types here to avoid doing import webview.internal.WVTypes

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
