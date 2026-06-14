using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class SavingView extends WatchUi.View {

    var _startMillis = 0;

    function initialize() {
        View.initialize();
        _startMillis = System.getTimer();
    }

    function onLayout(dc) {
    }

    function onUpdate(dc) {

        var elapsed = System.getTimer() - _startMillis;

        dc.clear();

        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_BLACK
        );

        var width = dc.getWidth();
        var height = dc.getHeight();

        var dotCycle = ((elapsed / 500) % 4).toNumber();
        var dots = "";
        for (var i = 0; i < dotCycle; i++) {
            dots += ".";
        }

        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_SMALL,
            "Saving" + dots,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // After ~2s return to main view
        if (elapsed >= 2000) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.requestUpdate();
            return;
        }

        WatchUi.requestUpdate();
    }
}

class SavingDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }
}
