#include <hxcpp.h>
#include <hxString.h>
#include <string>
#include "./vendor/webview.h"

#if defined(_WIN32)
#include <windef.h>
#include <winuser.h>
#include <processthreadsapi.h>
#endif

// Custom made to wrap WebView stuff 'n more for Haxe Externs

// Fix for webview_version
Dynamic hx_webview_version()
{
    const webview_version_info_t *ver = webview_version();

    hx::Anon sem = hx::Anon_obj::Create();

        sem->Add(HX_CSTRING("major"), (int)ver->version.major);
        sem->Add(HX_CSTRING("minor"), (int)ver->version.minor);
        sem->Add(HX_CSTRING("patch"), (int)ver->version.patch);

    hx::Anon out = hx::Anon_obj::Create();

        const std::string vNum = ver->version_number;
        const std::string prRel = ver->pre_release;
        const std::string bMeta = ver->build_metadata;

        out->Add(HX_CSTRING("version"), sem);
        out->Add(HX_CSTRING("version_number"), String::create(vNum.c_str()));
        out->Add(HX_CSTRING("pre_release"), String::create(prRel.c_str()));
        out->Add(HX_CSTRING("build_metadata"), String::create(bMeta.c_str()));

    return out;
}

// Fix for webview_get_native_handle
// Had to go with ints since I was breaking my head with the type of enum n shi (it was giving me ObjectPtr)
void *hx_get_native_handle(webview_t w, int kind)
{
    switch (kind)
    {
        case 0: return webview_get_native_handle(w, WEBVIEW_NATIVE_HANDLE_KIND_UI_WINDOW);
        case 1: return webview_get_native_handle(w, WEBVIEW_NATIVE_HANDLE_KIND_UI_WIDGET);
        case 2: return webview_get_native_handle(w, WEBVIEW_NATIVE_HANDLE_KIND_BROWSER_CONTROLLER);
        default: return nullptr;
    }
    return nullptr;
}

// Wrapper for webview_dispatch
using hxDispatchFunc = std::function<void(webview_t, Dynamic)>;

void hx_webview_dispatch(webview_t w, hxDispatchFunc fn, Dynamic arg)
{
    static_cast<webview::webview *>(w)->dispatch([=]() { fn(w, arg); });
}

// Wrapper for webview_bind
using hxBindFunc = std::function<void(String, String, Dynamic)>;

void hx_webview_bind(webview_t w, const char *name, hxBindFunc fn, Dynamic farg)
{
    static_cast<webview::webview *>(w)->bind(
        name, 
        [=](const std::string &seq, const std::string &req, void *arg)
        {
            fn(String::create(seq.c_str()), String::create(req.c_str()), farg);
        }, 
        nullptr);
}
