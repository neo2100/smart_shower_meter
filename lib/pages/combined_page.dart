import 'package:flutter/material.dart';
import '../models/shower_record.dart';
import 'timer_page.dart';
import 'smart_meter_page.dart';

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
