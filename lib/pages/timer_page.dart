import 'package:flutter/material.dart';
import '../models/shower_record.dart';
import '../services/database_service.dart';

class TimerPage extends StatefulWidget {
  final List<ShowerRecord> records;
  final Function(ShowerRecord) onRecordAdded;

  const TimerPage({
    super.key,
    required this.records,
    required this.onRecordAdded,
  });

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool _isRunning = false;
  bool _isPaused = false;
  Duration _elapsed = Duration.zero;
  late Stopwatch _stopwatch;
  int _recordIdCounter = 1;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _initializeIdCounter();
  }

  Future<void> _initializeIdCounter() async {
    final maxId = await _databaseService.getHighestId();
    setState(() {
      _recordIdCounter = maxId + 1;
    });
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
    });

    _updateTimer();
  }

  void _pauseTimer() {
    _stopwatch.stop();
    setState(() {
      _isPaused = true;
    });
  }

  void _stopTimer() {
    _stopwatch.stop();
    final record = ShowerRecord(
      id: _recordIdCounter++,
      startTime: DateTime.now().subtract(_stopwatch.elapsed),
      endTime: DateTime.now(),
      duration: _stopwatch.elapsed,
    );

    widget.onRecordAdded(record);

    _stopwatch.reset();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _elapsed = Duration.zero;
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
      appBar: AppBar(
        title: const Text('Shower Timer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            const SizedBox(height: 60),
            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start Button
                ElevatedButton.icon(
                  onPressed: !_isRunning || _isPaused ? _startTimer : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Pause Button
                ElevatedButton.icon(
                  onPressed: _isRunning && !_isPaused ? _pauseTimer : null,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Stop Button
                ElevatedButton.icon(
                  onPressed: _isRunning || _elapsed.inSeconds > 0
                      ? _stopTimer
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Status Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isRunning
                    ? Colors.green.withValues(alpha: 0.2 * 255)
                    : _elapsed.inSeconds > 0
                    ? Colors.orange.withValues(alpha: 0.2 * 255)
                    : Colors.grey.withValues(alpha: 0.2 * 255),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isRunning
                    ? (_isPaused ? 'Paused' : 'Shower Running...')
                    : _elapsed.inSeconds > 0
                    ? 'Ready to Save'
                    : 'Tap Start to Begin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isRunning
                      ? Colors.green[700]
                      : _elapsed.inSeconds > 0
                      ? Colors.orange[700]
                      : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }
}
