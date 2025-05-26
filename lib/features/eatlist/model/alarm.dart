class Alarm {
  final DateTime alarmTime;
  final bool taking;

  Alarm({
    required this.alarmTime,
    required this.taking,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      alarmTime: DateTime.parse(json['alarmTime']),
      taking: json['taking'],
    );
  }
}