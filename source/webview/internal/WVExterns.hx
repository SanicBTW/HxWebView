package webview.internal;

// WebViewExterns

import cpp.ConstCharStar;
import webview.WebView;

@:keep
@:noPrivateAccess
@:allow(webview.WebView)
@:buildXml("<include name=\"${haxelib:HxWebView}/include.xml\"/>")
@:include('internal/imports.h')
extern class WVExterns
{
    // Creates a new webview instance. If debug is non-zero - developer tools will
    // be enabled (if the platform supports them). The window parameter can be a
    // pointer to the native window handle. If it's non-null - then child WebView
    // is embedded into the given parent window. Otherwise a new window is created.
    // Depending on the platform, a GtkWindow, NSWindow or HWND pointer can be
    // passed here. Returns null on failure. Creation can fail for various reasons
    // such as when required runtime dependencies are missing or when window creation
    // fails.
    @:native('webview_create')
    private static function webview_create(debug:Int, ?window:WindowPtr):WindowPtr;

    // Destroys a webview and closes the native window.
    @:native('webview_destroy')
    private static function webview_destroy(w:WindowPtr):Void;

    // Runs the main loop until it's terminated. After this function exits - you
    // must destroy the webview.
    @:native('webview_run')
    private static function webview_run(w:WindowPtr):Void;

    // Stops the main loop. It is safe to call this function from another other
    // background thread.
    @:native('webview_terminate')
    private static function webview_terminate(w:WindowPtr):Void;

    // Posts a function to be executed on the main thread. You normally do not need
    // to call this function, unless you want to tweak the native window.
    @:native('hx_webview_dispatch')
    private static function webview_dispatch(w:WindowPtr, fn:DispatchFunc, arg:Dynamic):Void;

    // Returns a native window handle pointer. When using a GTK backend the pointer
    // is a GtkWindow pointer, when using a Cocoa backend the pointer is a NSWindow
    // pointer, when using a Win32 backend the pointer is a HWND pointer.
    @:native('webview_get_window')
    private static function webview_get_window(w:WindowPtr):WindowPtr;

    // Updates the title of the native window. Must be called from the UI thread.
    @:native('webview_set_title')
    private static function webview_set_title(w:WindowPtr, title:ConstCharStar):Void;

    // Updates the size of the native window. See WEBVIEW_HINT constants.
    @:native('webview_set_size')
    private static function webview_set_size(w:WindowPtr, width:Int, height:Int, hints:WebViewSizeHint):Void;

    // Navigates webview to the given URL. URL may be a properly encoded data URI.
    // Examples:
    // webview_navigate(w, "https://github.com/webview/webview");
    // webview_navigate(w, "data:text/html,%3Ch1%3EHello%3C%2Fh1%3E");
    // webview_navigate(w, "data:text/html;base64,PGgxPkhlbGxvPC9oMT4=");
    @:native('webview_navigate')
    private static function webview_navigate(w:WindowPtr, url:ConstCharStar):Void;

    // Set webview HTML directly.
    // Example: webview_set_html(w, "<h1>Hello</h1>");
    @:native('webview_set_html')
    private static function webview_set_html(w:WindowPtr, html:ConstCharStar):Void;

    // Injects JavaScript code at the initialization of the new page. Every time
    // the webview will open a new page - this initialization code will be
    // executed. It is guaranteed that code is executed before window.onload.
    @:native('webview_init')
    private static function webview_init(w:WindowPtr, js:ConstCharStar):Void;

    // Evaluates arbitrary JavaScript code. Evaluation happens asynchronously, also
    // the result of the expression is ignored. Use RPC bindings if you want to
    // receive notifications about the results of the evaluation.
    @:native('webview_eval')
    private static function webview_eval(w:WindowPtr, js:ConstCharStar):Void;

    // Binds a native C callback so that it will appear under the given name as a
    // global JavaScript function. Internally it uses webview_init(). The callback
    // receives a sequential request id, a request string and a user-provided
    // argument pointer. The request string is a JSON array of all the arguments
    // passed to the JavaScript function.
    @:native('hx_webview_bind')
    private static function webview_bind(w:WindowPtr, name:ConstCharStar, fn:BindFunc, arg:Dynamic):Void;

    // Removes a native C callback that was previously set by webview_bind.
    @:native('webview_unbind')
    private static function webview_unbind(w:WindowPtr, name:ConstCharStar):Void;

    // Responds to a binding call from the JS side. The ID/sequence number must
    // match the value passed to the binding handler in order to respond to the
    // call and complete the promise on the JS side. A status of zero resolves
    // the promise, and any other value rejects it. The result must either be a
    // valid JSON value or an empty string for the primitive JS value "undefined".
    @:native('webview_return')
    private static function webview_return(w:WindowPtr, seq:ConstCharStar, status:Int, result:ConstCharStar):Void;

    // Can be found on WebViewHelper.cpp
    // Get the library's version information.
    // @since 0.10
    @:native('hx_webview_version')
    private static function webview_version():WebViewInfo;

    // Can be found on WebViewHelper.cpp
    // Used to get the Main Window from the process, this behaves almost like webview_get_window if the WebView is a standalone Window
    @:native('find_main_window')
    private static function find_main_window():WindowPtr;
}
