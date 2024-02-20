// Custom made to wrap WebView stuff 'n more for Haxe Externs, basically a layer for making the code compatible without any issue

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

// Fix for webview_set_size
// Had to do the same approach as hx_get_native_handle, I don't know how to cast the hx enum to the c enum
void hx_set_size(webview_t w, int width, int height, int hints)
{
    switch (hints)
    {
        case 0: webview_set_size(w, width, height, WEBVIEW_HINT_NONE);
        case 1: webview_set_size(w, width, height, WEBVIEW_HINT_MIN);
        case 2: webview_set_size(w, width, height, WEBVIEW_HINT_MAX);
        case 3: webview_set_size(w, width, height, WEBVIEW_HINT_FIXED);
    }
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
