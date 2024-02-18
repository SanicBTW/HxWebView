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
    @:native('webview_create')
    private static function webview_create(debug:Int, ?window:WindowPtr):WindowPtr;

    @:native('webview_destroy')
    private static function webview_destroy(w:WindowPtr):Void;

    @:native('webview_run')
    private static function webview_run(w:WindowPtr):Void;

    @:native('webview_terminate')
    private static function webview_terminate(w:WindowPtr):Void;

    @:native('hx_webview_dispatch')
    private static function webview_dispatch(w:WindowPtr, fn:DispatchFunc, arg:Dynamic):Void;

    @:native('webview_get_window')
    private static function webview_get_window(w:WindowPtr):WindowPtr;

    // Returns a native handle of choice.
    // @since 0.11
    @:native('hx_get_native_handle')
    private static function webview_get_native_handle(w:WindowPtr, kind:WebViewNativeHandleKind):WindowPtr;

    @:native('webview_set_title')
    private static function webview_set_title(w:WindowPtr, title:ConstCharStar):Void;

    @:native('webview_set_size')
    private static function webview_set_size(w:WindowPtr, width:Int, height:Int, hints:WebViewSizeHint):Void;

    @:native('webview_navigate')
    private static function webview_navigate(w:WindowPtr, url:ConstCharStar):Void;

    @:native('webview_set_html')
    private static function webview_set_html(w:WindowPtr, html:ConstCharStar):Void;

    @:native('webview_init')
    private static function webview_init(w:WindowPtr, js:ConstCharStar):Void;

    @:native('webview_eval')
    private static function webview_eval(w:WindowPtr, js:ConstCharStar):Void;

    @:native('hx_webview_bind')
    private static function webview_bind(w:WindowPtr, name:ConstCharStar, fn:BindFunc, arg:Dynamic):Void;

    @:native('webview_unbind')
    private static function webview_unbind(w:WindowPtr, name:ConstCharStar):Void;

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
