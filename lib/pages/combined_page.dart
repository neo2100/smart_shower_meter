import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Shower Meter'),
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
                    records: widget.records,
                    onRecordAdded: widget.onRecordAdded,
                  )
                : TimerPage(
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
                    onChanged: (value) {
                      setState(() {
                        _isSmartMode = value;
                      });
                    },
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
