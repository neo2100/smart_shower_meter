using Toybox.Application;
using Toybox.WatchUi;

class SmartShowerMeterApp extends Application.AppBase {

    function initialize() {

        Application.AppBase.initialize();

        AppState.stopwatch =
            new StopwatchManager();
    }

    function getInitialView() {

        return [
            new SmartShowerMeterView(),
            new SmartShowerMeterDelegate()
        ];
    }
}