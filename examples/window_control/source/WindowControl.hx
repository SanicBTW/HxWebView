package;

import haxe.Json;
import webview.WebView;

class WindowControl
{
    private static var html:String = "
        <style>
            body
            {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
        </style>

        <p>Window Position: <span id='xPos'>?</span>x<span id='yPos'>?</p>
        <div>
            <label for='newX'>New X Position</label>
            <input type='number' id='newX' name='newX'>
            <br>
            <label for='newY'>New Y Position</label>
            <input type='number' id='newY' name='newY'>
            <br>
            <button onclick='
                var newX = document.getElementById(\"newX\").valueAsNumber;
                var newY = document.getElementById(\"newY\").valueAsNumber;
                window.setPosition(newX, newY).then(() =>
                {
                    window.getPosition().then(res =>
                    {
                        document.getElementById(\"xPos\").textContent = res.x;
                        document.getElementById(\"yPos\").textContent = res.y;
                    });
                });
            '>Set New Position</button>
        </div>
        <br>
        <label for='topmC'>TopMost</label>
        <input type='checkbox' name='topmC' id='topmC' onchange='
            window.setTopmost(this.checked ? 1 : 0);
        '>
        <br>
        <label for='winDec'>Window Decoration</label>
        <input type='checkbox' name='winDec' id='winDec' checked onchange='
            window.setDecoration(this.checked ? 1 : 0);
        '>

        <script>
            document.addEventListener('DOMContentLoaded', () =>
            {
                window.getPosition().then(res =>
                {
                    document.getElementById('xPos').textContent = res.x;
                    document.getElementById('yPos').textContent = res.y;
                });
            });
        </script>
    ";

    public static function main()
    {
        var w:WebView = new WebView(true);
        w.setHTML(html);
        w.setTitle("Window Control");

        w.bind("getPosition", (seq, req, arg) -> 
        {
            w.resolve(seq, 0, Json.stringify(w.getWindowPosition()));
        }, null);

        w.bind("setTopmost", (seq, req, arg) -> 
        {
            var args:Array<String> = req.substring(1, req.length - 1).split(",");
            w.setWindowTopmost(Std.parseInt(args[0]) == 1);
            w.resolve(seq, 0, "");
        }, null);

        w.bind('setPosition', (seq, req, arg) -> 
        {
            var args:Array<String> = req.substring(1, req.length - 1).split(",");
            var newX:Int = Std.parseInt(args[0]);
            var newY:Int = Std.parseInt(args[1]);
            w.setWindowPosition(newX, newY);
            w.resolve(seq, 0, "");
        }, null);

        w.bind("setDecoration", (seq, req, arg) -> 
        {
            var args:Array<String> = req.substring(1, req.length - 1).split(",");
            w.setWindowDecoration(Std.parseInt(args[0]) == 1);
            w.resolve(seq, 0, "");
        }, null);

        w.run();
        w.destroy();
    }
}