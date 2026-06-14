using Toybox.WatchUi;

class SmartShowerMeterDelegate
    extends WatchUi.BehaviorDelegate {

    function initialize() {

        BehaviorDelegate.initialize();
    }

    function onSelect() {
        AppState.stopwatch.startPause();
        WatchUi.requestUpdate();

        if (!AppState.stopwatch.isRunning()) {
            onMenu();
        }

        return true;
    }

    function onMenu() {
        var menu = new WatchUi.Menu();

        menu.addItem(
            Rez.Strings.menu_label_resume,
            :resume
        );

        menu.addItem(
            Rez.Strings.menu_label_save,
            :save
        );

        menu.addItem(
            Rez.Strings.menu_label_reset,
            :reset
        );

        WatchUi.pushView(
            menu,
            new MainMenuDelegate(),
            WatchUi.SLIDE_UP
        );
        return true;
    }
}