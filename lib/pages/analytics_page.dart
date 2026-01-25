import 'package:flutter/material.dart';
import '../models/shower_record.dart';

class AnalyticsPage extends StatefulWidget {
  final List<ShowerRecord> records;

  const AnalyticsPage({super.key, required this.records});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedDays = 7;

  Map<String, Duration> _getShowersByDay() {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: _selectedDays));
    final dayMap = <String, Duration>{};

    // Initialize all days with zero duration
    for (int i = 0; i < _selectedDays; i++) {
      final date = cutoffDate.add(Duration(days: i));
      final dateKey = '${date.month}/${date.day}/${date.year}';
      dayMap[dateKey] = Duration.zero;
    }

    // Add shower durations
    for (final record in widget.records) {
      if (record.startTime.isAfter(cutoffDate)) {
        final dateKey =
            '${record.startTime.month}/${record.startTime.day}/${record.startTime.year}';
        dayMap[dateKey] = (dayMap[dateKey] ?? Duration.zero) + record.duration;
      }
    }

    return dayMap;
  }

  Duration _getTotalDuration() {
    return widget.records.isEmpty
        ? Duration.zero
        : widget.records.fold<Duration>(
            Duration.zero,
            (sum, record) => sum + record.duration,
          );
  }

  Duration _getAverageDuration() {
    if (widget.records.isEmpty) return Duration.zero;
    final total = _getTotalDuration();
    return Duration(
      milliseconds: total.inMilliseconds ~/ widget.records.length,
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final showersByDay = _getShowersByDay();
    final totalDuration = _getTotalDuration();
    final averageDuration = _getAverageDuration();
    final maxDuration = showersByDay.values.isEmpty
        ? Duration.zero
        : showersByDay.values.reduce(
            (a, b) => a.inSeconds > b.inSeconds ? a : b,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Time Period Selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Select Time Period',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [7, 14, 30, 90].map((days) {
                        return FilterChip(
                          label: Text('${days}d'),
                          selected: _selectedDays == days,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDays = days;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Summary Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Time',
                      value: _formatDuration(totalDuration),
                      icon: Icons.timer,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Showers',
                      value: widget.records.length.toString(),
                      icon: Icons.shower,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Average',
                      value: _formatDuration(averageDuration),
                      icon: Icons.show_chart,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Chart Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Shower Time Per Day',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bar Chart
            if (showersByDay.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 250,
                  child: _ScrollableBarChart(
                    data: showersByDay,
                    maxValue: maxDuration,
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollableBarChart extends StatefulWidget {
  final Map<String, Duration> data;
  final Duration maxValue;

  const _ScrollableBarChart({required this.data, required this.maxValue});

  @override
  State<_ScrollableBarChart> createState() => _ScrollableBarChartState();
}

class _ScrollableBarChartState extends State<_ScrollableBarChart> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Scroll to the end (right) after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ScrollableBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to the end when data changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: _BarChart(data: widget.data, maxValue: widget.maxValue),
    );
  }
}

class _BarChart extends StatelessWidget {
  final Map<String, Duration> data;
  final Duration maxValue;

  const _BarChart({required this.data, required this.maxValue});

  String _getDayOfWeek(String dateKey) {
    final parts = dateKey.split('/');
    final month = int.parse(parts[0]);
    final day = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    final date = DateTime(year, month, day);

    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekDays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxSeconds = maxValue.inSeconds > 0 ? maxValue.inSeconds : 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: entries.map((entry) {
        final heightRatio = entry.value.inSeconds / maxSeconds;
        final displayDay = entry.key.split('/')[1]; // Show day only
        final dayOfWeek = _getDayOfWeek(entry.key);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 40,
                height: 180 * heightRatio,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                displayDay,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dayOfWeek,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
