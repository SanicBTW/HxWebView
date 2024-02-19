package;

import haxe.Json;
import webview.WebView;

using webview.WindowUtils;

class Decoration
{
    private static var isDecorated:Bool = true;

    private static var html:String = '
        <button id="setDecoration">Set Window Decoration</button>

        <script>
            const [setDecor] = 
                document.querySelectorAll("#setDecoration");

            document.addEventListener("DOMContentLoaded", () =>
            {
                setDecor.addEventListener("click", () =>
                {
                    window.setDecoration();
                });
            });
        </script>
    ';

    public static function main()
    {
        var w:WebView = new WebView();
        w.setHTML(html);
        w.setSize(480, 320, NONE);
        w.setTitle("Window Decoration");
        w.bind("setDecoration", (seq, req, arg) -> 
        {
            try 
            {
                w.setWindowDecoration(isDecorated = !isDecorated);
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