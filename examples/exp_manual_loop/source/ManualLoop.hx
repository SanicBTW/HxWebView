package;

import webview.WebView;

using webview.WindowUtils;

// This feature is really unstable and experimental.
// It will be improved sometime but for now it works as intended.
// It may still give errors up.
class ManualLoop
{
    public static function main()
    {
        var w:WebView = new WebView();
        w.setHTML("This Window is not being processed by the WebView Main Loop!");
        w.setSize(480, 320, NONE);
        w.setTitle("Manual Loop");

        // You MUST execute this function in order to make the WebView Window close as soon as the close button is clicked.
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