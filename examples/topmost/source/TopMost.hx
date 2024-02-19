package;

import haxe.Json;
import webview.WebView;

using webview.WindowUtils;

class TopMost
{
    private static var isTopMost:Bool = false;

    private static var html:String = '
        <button id="setTop">Set Window TopMost</button>

        <script>
            const [setTop] = 
                document.querySelectorAll("#setTop");

            document.addEventListener("DOMContentLoaded", () =>
            {
                setTop.addEventListener("click", () =>
                {
                    window.setTopmost();
                });
            });
        </script>
    ';

    public static function main()
    {
        var w:WebView = new WebView();
        w.setHTML(html);
        w.setSize(480, 320, NONE);
        w.setTitle("Window TopMost");
        w.bind("setTopmost", (seq, req, arg) -> 
        {
            try 
            {
                w.setWindowTopmost(isTopMost = !isTopMost);
                w.resolve(seq, 0, "");
            }
            catch(ex)
            {
                w.resolve(seq, 1, Json.stringify({err: '${ex.message}'}));
            }
        }, null);
        w.run();
    }
}