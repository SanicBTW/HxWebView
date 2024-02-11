package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import sys.thread.Thread;
import webview.WebView;

class PlayState extends FlxState
{
	private var head:FlxText;
	private var body:FlxText;
	private var spinning:FlxSprite;
	private var html:String = '
		<h1>Thanks for using webview!</h1>

		<!-- idk how to call it mb --> 
		<input id="content" type="text" placeholder="Send text to Game">
		<button id="sendText">Send text to Game</button>

		<script>
			const [ inputS, sendBtn ] = document.querySelectorAll("#content, #sendText");

			document.addEventListener("DOMContentLoaded", () =>
			{
				sendBtn.addEventListener("click", () =>
				{
					sendBtn.disabled = true;
					window.callOnGame(inputS.value).then(r =>
					{
						sendBtn.disabled = false;
					}).catch(e =>
					{
						console.log(e);
						alert("Failed to send to Game");
						sendBtn.disabled = false;
					});
				});
			});
		</script>
	';

	override public function create()
	{
		Thread.createWithEventLoop(() ->
		{
			var w:WebView = new WebView(#if debug true #end);

			w.setTitle("HxWebView x HaxeFlixel - WebView");
			w.setSize(480, 320, NONE);
			w.setHTML(html);

			Application.current.onExit.add((_) ->
			{
				w.terminate();
				w.destroy();
			});

			// Little note, you have to run the webview thread in order to work with binds and more stuff, basic operations like
			// navigating to a webpage should work without the need to create a thread
			// but if you want to manipulate variables from the main thread you will need to
			// create a thread and run the webview thread inside of it to avoid "Critical Error: Allocating from a GC-free thread"
			// also this approach isn't working correctly at all since it freezes after a couple of seconds

			w.bind("callOnGame", (seq, req, arg) ->
			{
				var args:Array<String> = req.substring(1, req.length - 1).split(",");
				body.text = formatString(args[0]);

				w.resolve(seq, 0, "");
			}, null);

			w.run();
		});

		add(spinning = new FlxSprite(0, 0).makeGraphic(100, 100, FlxColor.WHITE));
		spinning.screenCenter();

		add(head = new FlxText(50, 50, 0, "HaxeFlixel example", 32));
		add(body = new FlxText(50, 125, 0, "Waiting for input...", 24));

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		spinning.angle += Math.sin((Math.PI * (360 * elapsed)) / 360) * 50;
	}

	// Used to format arguments passed from the WebView
	private function formatString(s:String):String
	{
		return s.substring(1, s.length - 1);
	}
}
