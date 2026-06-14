using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Lang;

class SmartShowerMeterView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
    }

    function onUpdate(dc) {
        try {

            // If a save was requested from the menu, show the transient SavingView
            if (AppState.showSaving) {
                AppState.showSaving = false;
                WatchUi.pushView(
                    new SavingView(),
                    new SavingDelegate(),
                    WatchUi.SLIDE_UP
                );
                return;
            }
            
            dc.clear();

            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_BLACK
            );

            var width = dc.getWidth();
            var height = dc.getHeight();

            var elapsed =
                AppState.stopwatch.getElapsedSeconds();

            var minutes = elapsed / 60;
            var seconds = elapsed % 60;

            var timeText =
                Lang.format(
                    "$1$:$2$",
                    [
                        formatTwoDigits(minutes),
                        formatTwoDigits(seconds)
                    ]
                );

            var statusText =
                AppState.stopwatch.isRunning()
                    ? "Showering..."
                    : "Click on Start";

            // Stopwatch
            dc.drawText(
                width / 2,
                height * 0.25,
                Graphics.FONT_NUMBER_HOT,
                timeText,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // Status
            dc.drawText(
                width / 2,
                height * 0.65,
                Graphics.FONT_SMALL,
                statusText,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            WatchUi.requestUpdate();

        } catch (e) {
            System.println("SmartShowerMeterView.onUpdate: Exception: " + e.toString());
        }
    }

    function formatTwoDigits(value) {

        if (value < 10) {
            return "0" + value;
        }

        return value.toString();
    }
}