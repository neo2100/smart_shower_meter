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

    testWidgets('AppBar displays correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TimerPage(
            records: testRecords,
            onRecordAdded: (record) {
              testRecords.add(record);
            },
          ),
        ),
      );

      // Verify AppBar title
      expect(find.text('Shower Timer'), findsOneWidget);
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

      // Verify all button icons exist
      expect(find.byIcon(Icons.play_arrow), findsOneWidget); // Start
      expect(find.byIcon(Icons.pause), findsOneWidget); // Pause
      expect(find.byIcon(Icons.stop), findsOneWidget); // Stop
    });

    testWidgets('Start button is visible and labeled', (
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

      // Verify Start button with "Start" text
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('Pause button is visible and labeled', (
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

      // Verify Pause button with "Pause" text
      expect(find.text('Pause'), findsOneWidget);
    });

    testWidgets('Stop button is visible and labeled', (
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

      // Verify Stop button with "Stop" text
      expect(find.text('Stop'), findsOneWidget);
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
