using Toybox.WatchUi;
using Toybox.System;

class MainMenuDelegate
    extends WatchUi.MenuInputDelegate {

    function initialize() {

        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :resume) {
            try {
                AppState.stopwatch.startPause();
            } catch (e) {
                System.println("MainMenuDelegate.resume: Exception: " + e.toString());
            }
        }

        if (item == :save) {
            // Request showing the saving animation on the main view
            AppState.showSaving = true;
            AppState.stopwatch.reset();

        }

        if (item == :reset) {
            AppState.stopwatch.reset();
            WatchUi.requestUpdate();
        }
    }

}
