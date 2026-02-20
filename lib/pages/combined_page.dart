import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/shower_record.dart';
import 'timer_page.dart';
import 'smart_meter_page.dart';
import 'water_flow_config_page.dart';

class CombinedPage extends StatefulWidget {
  final List<ShowerRecord> records;
  final Function(ShowerRecord) onRecordAdded;

  const CombinedPage({
    super.key,
    required this.records,
    required this.onRecordAdded,
  });

  @override
  State<CombinedPage> createState() => _CombinedPageState();
}

class _CombinedPageState extends State<CombinedPage> {
  bool _isSmartMode = false; // false for timer, true for smart meter

  // Global keys to access child page states
  final GlobalKey<State<TimerPage>> _timerPageKey = GlobalKey();
  final GlobalKey<State<SmartMeterPage>> _smartMeterPageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _enableWakelock();
  }

  @override
  void deactivate() {
    // Save current record before leaving the page
    _saveRunningRecord();
    super.deactivate();
  }

  @override
  void dispose() {
    _disableWakelock();
    super.dispose();
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      if (kDebugMode) {
        print('Error enabling wakelock: $e');
      }
    }
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      if (kDebugMode) {
        print('Error disabling wakelock: $e');
      }
    }
  }

  /// Save the current running record from the active page
  void _saveRunningRecord() {
    if (_isSmartMode) {
      final state = _smartMeterPageKey.currentState;
      if (state != null && state is State<SmartMeterPage>) {
        (state as dynamic).saveCurrentRecord();
      }
    } else {
      final state = _timerPageKey.currentState;
      if (state != null && state is State<TimerPage>) {
        (state as dynamic).saveCurrentRecord();
      }
    }
  }

  void _handleModeSwitch(bool value) {
    // Save current record before switching if one is running
    _saveRunningRecord();

    setState(() {
      _isSmartMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shower Meter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WaterFlowConfigPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Water Flow Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isSmartMode
                ? SmartMeterPage(
                    key: _smartMeterPageKey,
                    records: widget.records,
                    onRecordAdded: widget.onRecordAdded,
                  )
                : TimerPage(
                    key: _timerPageKey,
                    records: widget.records,
                    onRecordAdded: widget.onRecordAdded,
                  ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Smart Meter'),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isSmartMode,
                    onChanged: _handleModeSwitch,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
