#pragma once

#if defined(_WIN32)
#include "windows/WebView2EnvironmentOptions.h"
#include "windows/WebView2.h"
#define WEBVIEW_MSWEBVIEW2_BUILTIN_IMPL 0
#endif

#include "vendor/webview.h"
#include "WebViewHelper.cpp"