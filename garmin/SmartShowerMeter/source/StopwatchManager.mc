using Toybox.System;

class StopwatchManager {

    var _running = false;
    var _startMillis = 0;
    var _elapsedMillis = 0;

    function initialize() {
    }

    function startPause() {

        if (_running) {

            _elapsedMillis +=
                (System.getTimer() - _startMillis);

            _running = false;

        } else {

            _startMillis = System.getTimer();

            _running = true;
        }
    }

    function reset() {

        _running = false;
        _startMillis = 0;
        _elapsedMillis = 0;
    }

    function getElapsedMillis() {

        if (_running) {

            return _elapsedMillis +
                (System.getTimer() - _startMillis);
        }

        return _elapsedMillis;
    }

    function getElapsedSeconds() {

        return (getElapsedMillis() / 1000).toNumber();
    }

    function isRunning() {
        return _running;
    }
}