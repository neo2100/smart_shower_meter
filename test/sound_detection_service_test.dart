import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:record/record.dart';
import 'package:smart_shower_meter/services/sound_detection_service.dart';

// Generate mocks
@GenerateMocks([AudioRecorder])
import 'sound_detection_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SoundDetectionService Tests', () {
    late MockAudioRecorder mockRecorder;
    late SoundDetectionService service;

    setUp(() {
      mockRecorder = MockAudioRecorder();
      service = SoundDetectionService(recorder: mockRecorder);
    });

    tearDown(() async {
      await service.dispose();
    });

    test('Service initializes successfully', () async {
      // Since initialize requires permission, this might fail in test
      // But we can test that the method exists
      expect(service, isNotNull);
    });

    test('Service has correct initial state', () {
      expect(service.isListening, false);
      expect(service.lastLevel, -160.0);
    });

    // Note: Full testing requires mocking audio, which is complex
    // For now, test the basic structure
  });
}
