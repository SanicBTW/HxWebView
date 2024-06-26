<img src="https://avatars.githubusercontent.com/u/4168812?s=200&v=4" align="right" width="150" height="150">

# HxWebView

Haxe/hxcpp @:native bindings for [webview](https://github.com/webview/webview).

---

This library only works with the Haxe `cpp` target via `hxcpp`.

---

## Installation
```
haxelib install HxWebView
```

or with git for the latest potentially unstable updates.

```
haxelib git HxWebView https://github.com/SanicBTW/HxWebView.git dev-0.1.0
```

## Linux Usage
In order to use the library in Linux you must have `webkit2gtk` and `gtk3` installed in your system.

You can check [this](https://github.com/webview/webview?tab=readme-ov-file#linux-and-bsd) file to see the specific name libraries for your distro.

### Regarding embedding
With the current header file, you should be able to embed the WebView into an existing window in any platform but it requires using widgets.

As I currently don't know how to use widgets on Haxe, embedding is somewhat a difficult topic.

However I will keep looking for a way to do it and keep y'all updated.

### Usage examples
Check out the [examples folder](https://github.com/SanicBTW/HxWebView/tree/master/examples) for examples on how you can use these webview bindings, the examples are the same as the [official](https://github.com/webview/webview/tree/master/examples) ones.

### Licensing
`HxWebView` is made available via the [MIT](https://github.com/SanicBTW/HxWebView/blob/master/LICENSE) license, the same license as [webview](https://github.com/webview/webview/blob/master/LICENSE).

--- 
Using [15/02](https://github.com/webview/webview/commit/c4833a42d30fecac6d8cbe5e4932dd4eed6bcab3) header file

Using [1.0.2420.47](https://www.nuget.org/packages/Microsoft.Web.WebView2/1.0.2420.47) WebView2 SDK and [124.0.2478.51 Fixed Version](https://developer.microsoft.com/en-us/microsoft-edge/webview2/?form=MA13LH&ch=1) WebView2 Runtime for the Embedded WebView DLLs