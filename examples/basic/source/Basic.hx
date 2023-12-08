package;

import webview.WebView;

class Basic
{
    static function main()
    {
        var w:WebView = new WebView();
        w.setTitle("Basic Example");
        w.setSize(480, 320, NONE);
        w.setHTML("Thanks for using webview!");
        w.run();
        w.destroy();
    }
}