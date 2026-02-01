import 'package:flutter/material.dart';
import '../models/shower_record.dart';

enum AnalyticsMetric { waterUsage, duration }

class AnalyticsPage extends StatefulWidget {
  final List<ShowerRecord> records;

  const AnalyticsPage({super.key, required this.records});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedDays = 7;
  AnalyticsMetric _selectedMetric = AnalyticsMetric.waterUsage;

  Map<String, double> _getMetricByDay() {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: _selectedDays));
    final dayMap = <String, double>{};

    for (int i = 0; i < _selectedDays; i++) {
      final date = cutoffDate.add(Duration(days: i));
      final key = '${date.month}/${date.day}/${date.year}';
      dayMap[key] = 0.0;
    }

    for (final record in widget.records) {
      if (record.startTime.isAfter(cutoffDate)) {
        final key =
            '${record.startTime.month}/${record.startTime.day}/${record.startTime.year}';

        dayMap[key] =
            (dayMap[key] ?? 0) +
            (_selectedMetric == AnalyticsMetric.waterUsage
                ? record.totalWaterUsage
                : record.duration.inMinutes.toDouble());
      }
    }

    return dayMap;
  }

  double _getTotalMetric() {
    if (widget.records.isEmpty) return 0.0;

    return widget.records.fold<double>(
      0.0,
      (sum, record) =>
          sum +
          (_selectedMetric == AnalyticsMetric.waterUsage
              ? record.totalWaterUsage
              : record.duration.inMinutes.toDouble()),
    );
  }

  double _getAverageMetric() {
    if (widget.records.isEmpty) return 0.0;
    return _getTotalMetric() / widget.records.length;
  }

  String _formatMetric(double value) {
    return _selectedMetric == AnalyticsMetric.waterUsage
        ? '${value.toStringAsFixed(2)} L'
        : '${value.toStringAsFixed(0)} min';
  }

  String get _chartTitle {
    return _selectedMetric == AnalyticsMetric.waterUsage
        ? 'Water Usage Per Day'
        : 'Shower Duration Per Day';
  }

  @override
  Widget build(BuildContext context) {
    final metricByDay = _getMetricByDay();
    final totalMetric = _getTotalMetric();
    final averageMetric = _getAverageMetric();
    final maxMetric = metricByDay.values.isEmpty
        ? 0.0
        : metricByDay.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Selectors
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _AnalyticsSelectorCard(
                      title: 'Time Period',
                      children: [7, 14, 30, 90].map((days) {
                        return FilterChip(
                          label: Text('${days}d'),
                          selected: _selectedDays == days,
                          onSelected: (_) {
                            setState(() => _selectedDays = days);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AnalyticsSelectorCard(
                      title: 'Metric',
                      children: [
                        ChoiceChip(
                          label: const Text('Water'),
                          selected:
                              _selectedMetric == AnalyticsMetric.waterUsage,
                          onSelected: (_) {
                            setState(() {
                              _selectedMetric = AnalyticsMetric.waterUsage;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Duration'),
                          selected: _selectedMetric == AnalyticsMetric.duration,
                          onSelected: (_) {
                            setState(() {
                              _selectedMetric = AnalyticsMetric.duration;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Summary Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total',
                      value: _formatMetric(totalMetric),
                      icon: _selectedMetric == AnalyticsMetric.waterUsage
                          ? Icons.water_drop
                          : Icons.timer,
                      color: _selectedMetric == AnalyticsMetric.waterUsage
                          ? Colors.blue
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Showers',
                      value: widget.records.length.toString(),
                      icon: Icons.shower,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Average',
                      value: _formatMetric(averageMetric),
                      icon: Icons.show_chart,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Chart Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _chartTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Chart
            if (metricByDay.isEmpty)
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
                    data: metricByDay,
                    maxValue: maxMetric,
                    barColor: _selectedMetric == AnalyticsMetric.waterUsage
                        ? Theme.of(context).colorScheme.primary
                        : Colors.green,
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

class _AnalyticsSelectorCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _AnalyticsSelectorCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: children),
        ],
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollableBarChart extends StatefulWidget {
  final Map<String, double> data;
  final double maxValue;
  final Color barColor;

  const _ScrollableBarChart({
    required this.data,
    required this.maxValue,
    required this.barColor,
  });

  @override
  State<_ScrollableBarChart> createState() => _ScrollableBarChartState();
}

class _ScrollableBarChartState extends State<_ScrollableBarChart> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: _BarChart(
        data: widget.data,
        maxValue: widget.maxValue,
        barColor: widget.barColor,
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final Map<String, double> data;
  final double maxValue;
  final Color barColor;

  const _BarChart({
    required this.data,
    required this.maxValue,
    required this.barColor,
  });

  String _getDayOfWeek(String dateKey) {
    final parts = dateKey.split('/');
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxVal = maxValue > 0 ? maxValue : 1.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: entries.map((entry) {
        final heightRatio = entry.value / maxVal;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 40,
                height: 180 * heightRatio,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.key.split('/')[1],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getDayOfWeek(entry.key),
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
