package;

import webview.WebView;

// This feature is really unstable and experimental.
// It will be improved sometime but for now it works as intended.
// It may still give errors up.

// Ok so, for some reason the GTK Window updates at 12FPS while on Windows the Native Window (Win32) updates at 60FPS, I'll look into it
class ManualLoop
{
    public static function main()
    {
        var w:WebView = new WebView();
        w.setHTML("This Window is not being processed by the WebView Main Loop!");
        w.setSize(480, 320, NONE);
        w.setTitle("Manual Loop");

        // You MUST execute this function in order to make the WebView Window close as soon as the close button is clicked.
        // This is not needed for Windows but for Linux
        w.addDestroySignal();
        while(w.isOpen())
        {
            if (w.eventsPending())
            {
                w.process();
            }
        }
        w.destroy();
    }
}