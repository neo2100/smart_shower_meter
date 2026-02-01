import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_shower_meter/pages/smart_meter_page.dart';
import 'package:smart_shower_meter/models/shower_record.dart';

void main() {
  group('SmartMeterPage Widget Tests', () {
    late List<ShowerRecord> testRecords;

    setUp(() {
      testRecords = [
        ShowerRecord(
          id: 1,
          startTime: DateTime.now(),
          duration: const Duration(minutes: 5),
          waterFlow: 0.1,
        ),
      ];
    });

    testWidgets('SmartMeterPage builds correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: SmartMeterPage(
            records: testRecords,
            onRecordAdded: (record) {},
          ),
        ),
      );

      // Check if the page builds without errors
      expect(find.text('Smart Mode Active'), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('Timer display shows initial state', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: SmartMeterPage(
            records: testRecords,
            onRecordAdded: (record) {},
          ),
        ),
      );

      // Check initial timer display
      expect(find.text('00:00:00'), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    // Note: Testing the timer logic requires mocking the sound detection service
    // and handling async operations, which is complex for unit tests
  });
}
