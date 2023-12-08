package webview.internal;

// WebViewTypes

import cpp.Pointer;
import cpp.Void as CVoid;

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

// I learnt that a void pointer is a data type which acts like a dynamic and you need to cast it in need to retrieve the data 
typedef WindowPtr = Pointer<CVoid>;

// Used in webview_dispatch
typedef DispatchFunc = (w:WindowPtr, arg:Dynamic)->Void;

// Window size hints
enum abstract WebViewSizeHint(Int) to Int from Int
{
    var NONE = 0;
    var MIN = 1;
    var MAX = 2;
    var FIXED = 3;
}

// Used in webview_bind
typedef BindFunc = (seq:String, req:String, arg:Dynamic)->Void;