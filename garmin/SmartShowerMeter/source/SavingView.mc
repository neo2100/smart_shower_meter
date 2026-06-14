using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class SavingView extends WatchUi.View {

    var _startMillis = 0;

    function initialize() {
        View.initialize();
        _startMillis = System.getTimer();
    }

    function onUpdate(dc) {

        var elapsed = System.getTimer() - _startMillis;

        dc.clear();

        var width  = dc.getWidth();
        var height = dc.getHeight();

        // Label
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.drawText(
            width / 2,
            height / 2 - 20,
            Graphics.FONT_SMALL,
            "Saving",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Spinner
        var cx = width / 2;
        var cy = height / 2;

        var radius = width * 0.45;

        // Full ring (background)
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);

        dc.drawCircle(cx, cy, radius);

        // Rotating blue arc
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);

        var angle = ((elapsed % 1000) * 360 / 1000).toNumber();

        // 90° segment rotating around circle
        dc.drawArc(
            cx,
            cy,
            radius,
            Graphics.ARC_CLOCKWISE,
            angle,
            angle + 90
        );

        if (elapsed >= 2000) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
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
