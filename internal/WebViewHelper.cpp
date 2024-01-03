#include <hxcpp.h>
#include <hxString.h>
#include <string>
#include "./webview/webview.h"

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
            fn(String::create(seq.c_str()), String::create(req.c_str()), static_cast<Dynamic>(&arg));
        }, 
        static_cast<void *>(&farg));
}

// Get the Parent/Main Window from current process, origin https://stackoverflow.com/a/21767578
#if defined(_WIN32)
struct HANDLE_DATA
{
    DWORD process_id;
    HWND window_handle;
};

HWND find_main_window();
BOOL CALLBACK enum_windows_callback(HWND handle, LPARAM lParam);
BOOL is_main_window(HWND handle);

HWND find_main_window()
{
    HANDLE_DATA data;
    data.process_id = GetCurrentProcessId();
    data.window_handle = 0;
    EnumWindows(enum_windows_callback, (LPARAM)&data);
    return data.window_handle;
}

BOOL CALLBACK enum_windows_callback(HWND handle, LPARAM lParam)
{
    HANDLE_DATA& data = *(HANDLE_DATA*)lParam;
    DWORD process_id;
    GetWindowThreadProcessId(handle, &process_id);
    if (data.process_id != process_id || !is_main_window(handle))
        return TRUE;
    data.window_handle = handle;
    return FALSE;
}

BOOL is_main_window(HWND handle)
{
    return GetWindow(handle, GW_OWNER) == (HWND)0 && IsWindowVisible(handle);
}
#endif

// TODO
#if defined(HX_LINUX)
Dynamic find_main_window();

Dynamic find_main_window()
{
    return 0;
}
#endif