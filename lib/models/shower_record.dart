class ShowerRecord {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final double waterFlow; // liters per second

  ShowerRecord({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.waterFlow,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration.inSeconds,
      'waterFlow': waterFlow,
    };
  }

  // Create from JSON
  factory ShowerRecord.fromJson(Map<String, dynamic> json) {
    return ShowerRecord(
      id: json['id'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      duration: Duration(seconds: json['duration'] as int),
      waterFlow:
          (json['waterFlow'] as num?)?.toDouble() ??
          0.1, // default 0.1 L/s if not set
    );
  }

  // Get formatted duration string (HH:MM:SS)
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get formatted date (MM/DD/YYYY)
  String get formattedDate {
    return '${startTime.month.toString().padLeft(2, '0')}/${startTime.day.toString().padLeft(2, '0')}/${startTime.year}';
  }

  // Get formatted time (HH:MM AM/PM)
  String get formattedTime {
    return '${startTime.hour % 12 == 0 ? 12 : startTime.hour % 12}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  // Get total water usage in liters
  double get totalWaterUsage => duration.inSeconds * waterFlow;

  // Get formatted water usage (X.XX L)
  String get formattedWaterUsage => '${totalWaterUsage.toStringAsFixed(2)} L';
}
