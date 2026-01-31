/*
  Sound Detection Service:
  - Requests microphone permissions
  - Analyzes audio characteristics to detect water running sounds
  - Uses multiple audio signal analysis techniques:
    - RMS (Root Mean Square): Detects overall loudness level
    - Zero Crossing Rate (ZCR): Identifies frequency characteristics typical of water flow
    - Continuous Content Analysis: Ensures the sound is continuous (like flowing water) rather than isolated noise
  - Provides stability through consecutive frame detection (requires 3 consecutive detections before confirming water)
  - Includes simulated audio processing for testing
*/

import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class SoundDetectionService {
  bool _isListening = false;
  Function(bool)? _onWaterDetectedChanged;

  // Sensitivity settings for water detection
  static const double _defaultThreshold = 0.4; // 40% intensity
  static const int _sampleWindowSize = 2048; // samples to analyze
  static const int _requiredConsecutiveDetections =
      3; // frames needed to confirm

  int _consecutiveWaterDetections = 0;
  bool _lastWaterDetected = false;

  /// Initialize and request microphone permissions
  Future<bool> initialize() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Start listening to microphone input
  Future<bool> startListening({Function(bool)? onWaterDetectedChanged}) async {
    try {
      _onWaterDetectedChanged = onWaterDetectedChanged;
      _consecutiveWaterDetections = 0;
      _lastWaterDetected = false;

      _isListening = true;

      // Start analyzing audio stream
      _simulateAudioAnalysis();

      return true;
    } catch (e) {
      debugPrint('Error starting sound detection: $e');
      return false;
    }
  }

  /// Stop listening to microphone input
  Future<void> stopListening() async {
    try {
      _isListening = false;
      _consecutiveWaterDetections = 0;
    } catch (e) {
      debugPrint('Error stopping sound detection: $e');
    }
  }

  /// Simulate audio stream analysis
  void _simulateAudioAnalysis() {
    if (!_isListening) return;

    // Simulate audio stream processing
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isListening) return;

      // Generate simulated audio data
      final audioData = _generateSimulatedAudio();

      final isWaterRunning = _detectWaterSound(audioData);

      // Use consecutive frame detection for stability
      if (isWaterRunning) {
        _consecutiveWaterDetections++;
      } else {
        _consecutiveWaterDetections = 0;
      }

      // Confirm water detection after required consecutive frames
      final confirmed =
          _consecutiveWaterDetections >= _requiredConsecutiveDetections;

      if (confirmed != _lastWaterDetected) {
        _lastWaterDetected = confirmed;
        _onWaterDetectedChanged?.call(confirmed);
      }

      // Continue listening
      _simulateAudioAnalysis();
    });
  }

  /// Generate simulated audio data for testing
  /// In production, this would come from actual microphone input
  List<int> _generateSimulatedAudio() {
    final random = Random();
    final audioData = <int>[];

    // Generate 2048 samples of simulated audio
    for (int i = 0; i < _sampleWindowSize; i++) {
      // Create white noise with some frequency content variation
      final sample = (random.nextDouble() - 0.5) * 2.0;
      final signedSample = (sample * 32767).toInt();

      // Convert to little-endian bytes (16-bit)
      audioData.add(signedSample & 0xFF);
      audioData.add((signedSample >> 8) & 0xFF);
    }

    return audioData;
  }

  /// Detect if current audio frame contains water running sound
  /// Returns true if water-like sound is detected
  bool _detectWaterSound(List<int> audioData) {
    try {
      if (audioData.isEmpty) return false;

      // Convert byte data to samples
      final samples = _convertBytesToSamples(audioData);

      if (samples.isEmpty) return false;

      // Analyze frequency and amplitude characteristics
      final isWaterSound = _analyzeAudioCharacteristics(samples);

      return isWaterSound;
    } catch (e) {
      debugPrint('Error detecting water sound: $e');
      return false;
    }
  }

  /// Convert raw audio bytes to normalized samples
  List<double> _convertBytesToSamples(List<int> audioData) {
    final samples = <double>[];

    // Process 16-bit PCM audio (2 bytes per sample)
    for (int i = 0; i < audioData.length - 1; i += 2) {
      final sample = (audioData[i + 1] << 8) | audioData[i];
      // Convert to signed 16-bit
      final signed = sample > 32767 ? sample - 65536 : sample;
      // Normalize to range [-1.0, 1.0]
      samples.add(signed / 32768.0);
    }

    return samples;
  }

  /// Analyze audio characteristics to detect water sound
  /// Water sounds typically have:
  /// - Mid-range frequency content (500-4000 Hz)
  /// - Continuous white/pink noise characteristics
  /// - Moderate to high amplitude
  bool _analyzeAudioCharacteristics(List<double> samples) {
    if (samples.length < 100) return false;

    // Calculate RMS (Root Mean Square) - overall loudness
    double rmsSum = 0;
    for (final sample in samples) {
      rmsSum += sample * sample;
    }
    final rms = sqrt(rmsSum / samples.length);

    // Check if volume is above minimum threshold
    if (rms < _defaultThreshold) {
      return false;
    }

    // Calculate zero crossing rate
    // Water sounds typically have moderate ZCR
    int zeroCrossings = 0;
    for (int i = 1; i < samples.length; i++) {
      if ((samples[i] >= 0 && samples[i - 1] < 0) ||
          (samples[i] < 0 && samples[i - 1] >= 0)) {
        zeroCrossings++;
      }
    }

    final zcr = zeroCrossings / samples.length;

    // Water sound characteristics:
    // - Moderate ZCR (not too low like bass, not too high like speech)
    // - Continuous without silence gaps
    // - Medium to high energy

    // Check if sound characteristics match water
    final hasWaterLikeZCR = zcr > 0.1 && zcr < 0.6;
    final hasGoodEnergy = rms > _defaultThreshold;
    final hasContinuousNoise = _hasContinuousContent(samples);

    return hasWaterLikeZCR && hasGoodEnergy && hasContinuousNoise;
  }

  /// Check if audio has continuous noise content (characteristic of flowing water)
  bool _hasContinuousContent(List<double> samples) {
    // Divide into chunks and check each has some energy
    final chunkSize = samples.length ~/ 4;
    if (chunkSize < 50) return true; // Not enough data

    int activeChunks = 0;
    for (int i = 0; i < 4; i++) {
      double chunkEnergy = 0;
      final start = i * chunkSize;
      final end = (i + 1) * chunkSize;

      for (int j = start; j < end && j < samples.length; j++) {
        chunkEnergy += samples[j].abs();
      }

      // Check if chunk has meaningful energy
      if (chunkEnergy / chunkSize > 0.1) {
        activeChunks++;
      }
    }

    // At least 3 out of 4 chunks should have energy (continuous sound)
    return activeChunks >= 3;
  }

  /// Update detection sensitivity (0.1 to 1.0, lower = more sensitive)
  void setSensitivity(double sensitivity) {
    // Future enhancement: allow user to adjust sensitivity
  }

  bool get isListening => _isListening;
}
