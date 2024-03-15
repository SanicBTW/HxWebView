package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import webview.WebView;

class PlayState extends FlxState
{
	var w:WebView;
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
		// When running on a thread using the manual loop, the game will eventually stop updating, dispatching a bind (?) will start the update cycle again
		// This behaviour is kind of weird
		// Maybe this is a dirty workaround but its somehow working for now so we can't really complain about it :sob:

		sys.thread.Thread.createWithEventLoop(() ->
		{
			w = new WebView(#if debug true #end);
			w.setTitle("HxWebView x HaxeFlixel - WebView");
			w.setSize(480, 320, NONE);
			w.setHTML(html);
			w.addDestroySignal();

			Application.current.window.onClose.add(() ->
			{
				if (w != null)
				{
					w.destroy();
					w = null;
				}
			});

			w.bind("callOnGame", (seq, req, arg) ->
			{
				var args:Array<String> = req.substring(1, req.length - 1).split(",");
				body.text = formatString(args[0]);
				w.resolve(seq, 0, "");
			}, null);

			while (true)
			{
				if (w.isOpen())
				{
					// To keep the Main Thread active and never stop freezing (?)
					sys.thread.Thread.processEvents();
					if (w.eventsPending())
						w.process();
				}
				else
					break;
			}

			if (w != null)
			{
				w.destroy();
				w = null;
			}

			return;
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
