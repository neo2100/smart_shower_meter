import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/shower_record.dart';
import '../services/database_service.dart';
import '../services/sound_detection_service.dart';

class SmartMeterPage extends StatefulWidget {
  final List<ShowerRecord> records;
  final Function(ShowerRecord) onRecordAdded;

  const SmartMeterPage({
    super.key,
    required this.records,
    required this.onRecordAdded,
  });

  @override
  State<SmartMeterPage> createState() => _SmartMeterPageState();
}

class _SmartMeterPageState extends State<SmartMeterPage> {
  late SoundDetectionService _soundDetectionService;
  bool _waterDetected = false;
  bool _isRunning = false;
  bool _isPaused = false;
  Duration _elapsed = Duration.zero;
  late Stopwatch _stopwatch;
  int _recordIdCounter = 1;
  final DatabaseService _databaseService = DatabaseService();
  double _waterFlow = 0.1; // L/s
  double _waterUsageCostFactor = 0.002; // euros per liter
  String _statusMessage = 'Initializing...';

  double _currentSoundLevel = -160.0;
  Timer? _uiUpdateTimer;
  double _silenceThreshold = -50.0;
  double _waterThreshold = -5.2;

  @override
  void initState() {
    super.initState();
    _soundDetectionService = SoundDetectionService();
    _stopwatch = Stopwatch();
    _initializeSmartMeter();
  }

  Future<void> _initializeSmartMeter() async {
    try {
      // Initialize sound detection
      final permissionGranted = await _soundDetectionService.initialize();

      if (!permissionGranted) {
        if (mounted) {
          setState(() {
            _statusMessage = 'Microphone permission denied';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone permission is required for Smart Meter',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Set initial thresholds
      _soundDetectionService.setSilenceThreshold(_silenceThreshold);
      _soundDetectionService.setWaterThreshold(_waterThreshold);

      // Initialize ID counter
      final maxId = await _databaseService.getHighestId();
      final waterFlow = await _databaseService.getWaterFlow();
      final costFactor = await _databaseService.getWaterUsageCostFactor();

      if (mounted) {
        setState(() {
          _recordIdCounter = maxId + 1;
          _waterFlow = waterFlow;
          _waterUsageCostFactor = costFactor;
          _statusMessage = 'Ready to start. Place near water source.';
        });
      }

      // Start listening for water sounds
      await _soundDetectionService.startListening(
        onWaterDetectedChanged: _onWaterDetectionChanged,
      );

      // Start UI update timer to show current sound level
      _uiUpdateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (mounted) {
          setState(() {
            _currentSoundLevel = _soundDetectionService.lastLevel;
            _elapsed = Duration(milliseconds: _stopwatch.elapsedMilliseconds);
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error initializing: $e';
        });
      }
    }
  }

  void _onWaterDetectionChanged(bool detected) {
    setState(() {
      _waterDetected = detected;
    });

    if (detected && !_isRunning) {
      // Water detected - start timer
      _startTimer();
    } else if (detected && _isRunning && _isPaused) {
      // Water detected again - resume timer
      _resumeTimer();
    } else if (!detected && _isRunning && !_isPaused) {
      // Water stopped - pause timer immediately
      _pauseTimer();
    }
  }

  void _startTimer() {
    if (!_isPaused) {
      _stopwatch.start();
    } else {
      _stopwatch.start();
      _isPaused = false;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _statusMessage = 'Water detected - Timer running';
    });

    _updateTimer();
  }

  void _pauseTimer() {
    _stopwatch.stop();
    setState(() {
      _isPaused = true;
      _statusMessage = 'Water paused - waiting to resume or stop';
    });
  }

  void _resumeTimer() {
    _stopwatch.start();
    setState(() {
      _isPaused = false;
      _statusMessage = 'Water detected again - Timer resumed';
    });
  }

  void _stopTimer() {
    _stopwatch.stop();
    final record = ShowerRecord(
      id: _recordIdCounter++,
      startTime: DateTime.now().subtract(_stopwatch.elapsed),
      endTime: DateTime.now(),
      duration: _stopwatch.elapsed,
      waterFlow: _waterFlow,
      waterUsageCostFactor: _waterUsageCostFactor,
    );

    widget.onRecordAdded(record);

    _stopwatch.reset();

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _elapsed = Duration.zero;
      _statusMessage = 'Ready to start. Place near water source.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Shower recorded: ${record.formattedDuration}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Public method to save current record if timer is running
  void saveCurrentRecord() {
    if (_isRunning || _elapsed.inSeconds > 0) {
      _stopTimer();
    }
  }

  /// Check if a record is currently being recorded
  bool isRecording() {
    return _isRunning || _elapsed.inSeconds > 0;
  }

  void _updateTimer() {
    if (_isRunning && !_isPaused) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _elapsed = _stopwatch.elapsed;
          });
          _updateTimer();
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Smart Meter Status Indicator
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _waterDetected
                      ? Colors.blue.withValues(alpha: 0.3 * 255)
                      : Colors.grey.withValues(alpha: 0.2 * 255),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _waterDetected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Water detection indicator
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _waterDetected ? Colors.blue : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _waterDetected ? 'Water Detected' : 'Listening...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _waterDetected
                                ? Colors.blue[900]
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: _waterDetected
                            ? Colors.blue[700]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Timer Display
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Text(
                  _formatDuration(_elapsed),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Mode Information
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Smart Mode Active',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Timer starts/pauses automatically with water flow',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Control Button - Toggle Start/Stop
              ElevatedButton.icon(
                onPressed: _isRunning
                    ? _stopTimer
                    : (!_isRunning && _elapsed.inSeconds > 0)
                    ? _stopTimer
                    : _startTimer,
                icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(_isRunning ? 'Stop & Save' : 'Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Sound Level Indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1 * 255),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Text(
                      'Sound Level: ${_currentSoundLevel.toStringAsFixed(1)} dB',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value:
                          ((_currentSoundLevel + 80).clamp(0, 80)) /
                          80, // Scale from -80 to 0 dB
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _currentSoundLevel >= _waterThreshold
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Silence: ${_silenceThreshold.toStringAsFixed(1)} dB',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Water: ${_waterThreshold.toStringAsFixed(1)} dB',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Adjust Thresholds:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Silence: ',
                            style: TextStyle(fontSize: 12),
                          ),
                          Expanded(
                            child: Slider(
                              value: _silenceThreshold,
                              min: -100,
                              max: -20,
                              divisions: 80,
                              label: _silenceThreshold.toStringAsFixed(1),
                              onChanged: (value) {
                                setState(() {
                                  _silenceThreshold = value;
                                  _soundDetectionService.setSilenceThreshold(
                                    value,
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Water: ', style: TextStyle(fontSize: 12)),
                          Expanded(
                            child: Slider(
                              value: _waterThreshold,
                              min: -80,
                              max: 0,
                              divisions: 80,
                              label: _waterThreshold.toStringAsFixed(1),
                              onChanged: (value) {
                                setState(() {
                                  _waterThreshold = value;
                                  _soundDetectionService.setWaterThreshold(
                                    value,
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _uiUpdateTimer?.cancel();
    _soundDetectionService.stopListening();
    _soundDetectionService.dispose();
    super.dispose();
  }
}
