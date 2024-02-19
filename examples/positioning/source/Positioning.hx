package;

import haxe.Json;
import webview.WebView;

using webview.WindowUtils;

class Positioning
{
    private static var html:String = '
    
        <button id="getPos">Get Window Position</button>
        <div>The current window position is: <span id="wX">?</span>x<span id="wY">?</span>.</div>

        <button id="setPos">Set Window Position</button>
        <input type="number" id="newX">x<input type="number" id="newY">

        <script>
            // NOTE: DOM Ordering is important for querySelectorAll to work properly
            const [posBtn, posX, posY, setBtn, newX, newY] = 
                document.querySelectorAll("#getPos, #wX, #wY, #setPos, #newX, #newY");

            document.addEventListener("DOMContentLoaded", () =>
            {
                posBtn.addEventListener("click", () =>
                {
                    window.getPosition().then(result =>
                    {
                        posX.textContent = result.x;
                        posY.textContent = result.y;
                    });
                });

                setBtn.addEventListener("click", () =>
                {
                    window.setPosition(newX.valueAsNumber, newY.valueAsNumber).then(result =>
                    {
                        posBtn.click();
                    });
                });
            });
        </script>
    ';

    public static function main()
    {
        var w:WebView = new WebView();
        w.setHTML(html);
        w.setSize(480, 320, NONE);
        w.setTitle("Window Positioning");
        w.bind('getPosition', (seq, req, arg) -> 
        {
            try
            {
                var pos:WindowPosition = w.getWindowPosition();
                w.resolve(seq, 0, Json.stringify(pos));
            }
            catch(ex)
            {
                w.resolve(seq, 1, Json.stringify({err: '${ex.message}'}));
            }
        }, null);
        w.bind('setPosition', (seq, req, arg) -> 
        {
            try 
            {
                var args:Array<String> = req.substring(1, req.length - 1).split(",");
                var newX:Int = Std.parseInt(args[0]);
                var newY:Int = Std.parseInt(args[1]);
                w.setWindowPosition(newX, newY);
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