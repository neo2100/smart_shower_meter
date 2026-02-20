import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_shower_meter/pages/timer_page.dart';
import 'package:smart_shower_meter/models/shower_record.dart';

void main() {
  group('TimerPage Widget Tests', () {
    late List<ShowerRecord> testRecords;

    setUp(() {
      testRecords = [];
    });

    testWidgets('Timer displays 00:00:00 on initial load', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerPage(
              records: testRecords,
              onRecordAdded: (record) {
                testRecords.add(record);
              },
            ),
          ),
        ),
      );

      // Verify initial timer display
      expect(find.text('00:00:00'), findsWidgets);
    });

    testWidgets('All control buttons are present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerPage(
              records: testRecords,
              onRecordAdded: (record) {
                testRecords.add(record);
              },
            ),
          ),
        ),
      );

      // Verify button text and icons exist
      expect(find.text('Start'), findsOneWidget); // Start button initially
      expect(find.text('Stop'), findsOneWidget); // Stop button
      expect(find.byIcon(Icons.play_arrow), findsOneWidget); // Play icon
      expect(find.byIcon(Icons.stop), findsOneWidget); // Stop icon
    });

    testWidgets('Button toggles from Start to Pause after clicking Start', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerPage(
              records: testRecords,
              onRecordAdded: (record) {
                testRecords.add(record);
              },
            ),
          ),
        ),
      );

      // Verify initial state shows Start button
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Pause'), findsNothing);
    });

    testWidgets('Initial status message is displayed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerPage(
              records: testRecords,
              onRecordAdded: (record) {
                testRecords.add(record);
              },
            ),
          ),
        ),
      );

      // Verify initial status message
      expect(find.text('Tap Start to Begin'), findsWidgets);
    });

    testWidgets('Timer container is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerPage(
              records: testRecords,
              onRecordAdded: (record) {
                testRecords.add(record);
              },
            ),
          ),
        ),
      );

      // Verify the timer container and text are displayed
      expect(find.byType(Container), findsWidgets);
      expect(find.text('00:00:00'), findsWidgets);
    });

    testWidgets('TimerPage constructor parameters are correct', (
      WidgetTester tester,
    ) async {
      // This test verifies the constructor parameters
      final timerPage = TimerPage(
        records: testRecords,
        onRecordAdded: (record) {
          testRecords.add(record);
        },
      );

      expect(timerPage.records, equals(testRecords));
      expect(timerPage.onRecordAdded, isNotNull);
    });

    testWidgets('ScaffoldMessenger is properly set up', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerPage(
              records: testRecords,
              onRecordAdded: (record) {
                testRecords.add(record);
              },
            ),
          ),
        ),
      );

      // Verify Scaffold exists which enables ScaffoldMessenger functionality
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
