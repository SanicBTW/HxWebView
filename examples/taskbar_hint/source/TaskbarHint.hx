package;

import haxe.Json;
import webview.WebView;

using webview.WindowUtils;

class TaskbarHint
{
    private static var isTaskbarHint:Bool = true;

    private static var html:String = '
        <h1>Depending on your Window Manager it will keep showing the Window Icon on the Taskbar and/or disable the minimize button from the Title Bar</h1>
        <button id="setTbHint">Set Window Taskbar Hint</button>

        <script>
            const [setTbHint] = 
                document.querySelectorAll("#setTbHint");

            document.addEventListener("DOMContentLoaded", () =>
            {
                setTbHint.addEventListener("click", () =>
                {
                    window.setTaskbarHint();
                });
            });
        </script>
    ';

    public static function main()
    {
        var w:WebView = new WebView();
        w.setHTML(html);
        w.setSize(480, 320, NONE);
        w.setTitle("Window Taskbar Hint");
        w.bind("setTaskbarHint", (seq, req, arg) -> 
        {
            try 
            {
                w.setWindowTaskbarHint(isTaskbarHint = !isTaskbarHint);
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