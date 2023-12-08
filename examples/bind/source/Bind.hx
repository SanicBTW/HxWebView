package;

import sys.thread.Thread;
import haxe.Json;
import webview.WebView;

class Bind
{
    static var html:String = '
    
        <button id="increment">Tap me</button>
        <div>You tapped <span id="count">0</span> time(s).</div>

        <button id="compute">Compute</button>
        <div>Result of computation: <span id="compute-result">0</span></div>

        <script>
            const [incrementElement, countElement, computeElement, computeResultElement] = 
                document.querySelectorAll("#increment, #count, #compute, #compute-result");

            document.addEventListener("DOMContentLoaded", () =>
            {
                incrementElement.addEventListener("click", () =>
                {
                    window.increment().then(result => 
                    {
                        countElement.textContent = result.count;
                    });
                });

                computeElement.addEventListener("click", () =>
                {
                    computeElement.disabled = true;
                    window.compute(6, 7).then(result => 
                    {
                        computeResultElement.textContent = result;
                        computeElement.disabled = false;
                    });
                });
            });
        </script>
    
    ';

    static function main()
    {
        var count:Int = 0;

        var w:WebView = new WebView(true);
        w.setTitle("Bind Example");
        w.setSize(480, 320, NONE);

        w.bind('increment', (seq, _, arg) -> 
        {
            w.resolve(seq, 0, Json.stringify({
                count: Std.string(count++)
            }));
        }, null);

        w.bind('compute', (seq, req, _) -> 
        {
            Thread.create(() ->
            {
                Sys.sleep(1);
                var args:Array<String> = req.substring(1, req.length - 1).split(",");
                var left:Int = Std.parseInt(args[0]);
                var right:Int = Std.parseInt(args[1]);
                var res:String = Std.string(left * right);
                w.resolve(seq, 0, res);
            });
        }, null);

        w.setHTML(html);
        w.run();
        w.destroy();
    }
}