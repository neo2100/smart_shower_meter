/*
  Sound Detection Service:
  - Platform-aware audio recording (mobile AND web with real microphone)
  - Captures REAL audio from device microphone on both platforms
  - Analyzes audio levels to detect water running sounds
  - Uses audio decibel levels with threshold-based detection
  - Provides stability through consecutive frame detection
  - Mobile: Uses flutter_sound with native codec
  - Web: Uses Web Audio API with getUserMedia for real microphone input
*/

import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:math';

class SoundDetectionService {
  final AudioRecorder _recorder;
  bool _isListening = false;
  Function(bool)? _onWaterDetectedChanged;
  StreamSubscription<Uint8List>? _recordingSubscription;
  Timer? _analysisTimer;

  // Detection parameters
  static double _silenceThresholdDb = -50.0;
  static double _waterThresholdDb = -5.2;
  static const int _requiredConsecutiveDetections = 10;
  static const int _fftSize = 1024;
  static const int _sampleRate = 16000;

  int _consecutiveWaterDetections = 0;
  int _consecutiveSilenceDetections = 0;
  bool _lastWaterDetected = false;
  double _lastLevel = -160.0;

  List<int> _audioBuffer = [];

  SoundDetectionService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  /// Initialize and request microphone permissions
  Future<bool> initialize() async {
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('❌ Microphone permission denied');
        return false;
      }

      debugPrint('✅ Audio recorder initialized');
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing sound detection: $e');
      return false;
    }
  }

  /// Start listening to microphone input
  Future<bool> startListening({Function(bool)? onWaterDetectedChanged}) async {
    try {
      _onWaterDetectedChanged = onWaterDetectedChanged;
      _consecutiveWaterDetections = 0;
      _consecutiveSilenceDetections = 0;
      _lastWaterDetected = false;
      _isListening = true;
      _audioBuffer = [];

      debugPrint('🎙️ Starting microphone recording');

      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ),
      );

      _recordingSubscription = stream.listen(
        (data) => _processAudioData(data),
        onError: (error) {
          debugPrint('❌ Recording error: $error');
          _isListening = false;
        },
        onDone: () {
          debugPrint('Recording done');
          _isListening = false;
        },
      );

      debugPrint('✅ Microphone recording started successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error starting sound detection: $e');
      _isListening = false;
      return false;
    }
  }

  /// Process audio level data from mobile recorder
  void _processAudioData(Uint8List data) {
    if (!_isListening) return;

    // Convert Uint8List to Int16List (PCM16)
    final pcmData = data.buffer.asInt16List();

    // Add to buffer
    _audioBuffer.addAll(pcmData);

    // Process in chunks
    while (_audioBuffer.length >= _fftSize) {
      final chunk = _audioBuffer.sublist(0, _fftSize);
      _audioBuffer.removeRange(0, _fftSize);

      _processAudioChunk(chunk);
    }
  }

  void _processAudioChunk(List<int> chunk) {
    try {
      // Convert to double
      final samples = chunk.map((e) => e.toDouble()).toList();

      // Calculate RMS (Root Mean Square)
      double sumSquares = 0;
      for (final sample in samples) {
        sumSquares += sample * sample;
      }
      final rms = sqrt(sumSquares / samples.length);
      // dBFS (decibels full scale): 0 dB = max amplitude (32768 for int16)
      final decibels = rms > 0 ? 20 * (log(rms / 32768) / log(10)) : -160.0;

      _lastLevel = decibels;

      // Detect water based on decibel level
      final isWaterRunning = _isWaterSound(decibels);

      // Use consecutive frame detection for stability
      if (isWaterRunning) {
        _consecutiveWaterDetections++;
        _consecutiveSilenceDetections = 0;
      } else {
        _consecutiveSilenceDetections++;
        _consecutiveWaterDetections = 0;
      }

      // Confirm water detection after required consecutive frames
      final bool shouldReportWater =
          _consecutiveWaterDetections >= _requiredConsecutiveDetections;
      final bool shouldReportSilence =
          _consecutiveSilenceDetections >= _requiredConsecutiveDetections;

      if (shouldReportWater && !_lastWaterDetected) {
        _lastWaterDetected = true;
        debugPrint('🌊 Water DETECTED (${decibels.toStringAsFixed(1)} dB)');
        _onWaterDetectedChanged?.call(true);
      } else if (shouldReportSilence && _lastWaterDetected) {
        _lastWaterDetected = false;
        debugPrint('🔇 No water (${decibels.toStringAsFixed(1)} dB)');
        _onWaterDetectedChanged?.call(false);
      }
    } catch (e) {
      debugPrint('❌ Error processing audio chunk: $e');
    }
  }

  /// Determine if audio level indicates water sound
  bool _isWaterSound(double decibels) {
    // Too quiet = silence
    if (decibels < _silenceThresholdDb) {
      return false;
    }

    // Too loud = clipping/distortion
    if (decibels > -2.0) {
      return false;
    }

    // Water typically in range of -40 to -10 dB
    return decibels >= _waterThresholdDb;
  }

  /// Stop listening to microphone input
  Future<void> stopListening() async {
    try {
      _isListening = false;
      _analysisTimer?.cancel();
      await _recordingSubscription?.cancel();
      await _recorder.stop();
      _consecutiveWaterDetections = 0;
      _consecutiveSilenceDetections = 0;
    } catch (e) {
      debugPrint('❌ Error stopping sound detection: $e');
    }
  }

  /// Cleanup resources
  Future<void> dispose() async {
    _isListening = false;
    _analysisTimer?.cancel();
    await _recordingSubscription?.cancel();
    await _recorder.dispose();
  }

  bool get isListening => _isListening;
  double get lastLevel => _lastLevel;

  void setSilenceThreshold(double threshold) {
    _silenceThresholdDb = threshold;
  }

  void setWaterThreshold(double threshold) {
    _waterThresholdDb = threshold;
  }
}

/// Extension to calculate sqrt and log for numbers
extension NumExtension on num {
  double sqrt() {
    return (this as double).sqrt();
  }

  double log() {
    return (this as double).log();
  }
}
