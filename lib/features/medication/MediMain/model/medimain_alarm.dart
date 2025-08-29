// lib/features/medication/MediMain/model/medimain_alarm.dart
class Alarm {
  final DateTime alarmTime;
  bool taking;

  Alarm({
    required this.alarmTime,
    required this.taking,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    // 서버가 ISO8601 문자열을 보낸다고 가정.
    final dt = DateTime.parse(json['alarmTime'] as String).toLocal();
    return Alarm(
      alarmTime: dt,
      taking: json['taking'] == true || json['taking'] == 1 || json['taking'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alarmTime': alarmTime.toUtc().toIso8601String(),
      'taking': taking,
    };
  }

  /// 현재 시간(now)이 [alarmTime - before] ~ [alarmTime + after] 사이면 true
  bool isWithinWindow(DateTime now, {Duration before = const Duration(hours: 1), Duration after = const Duration(hours: 1)}) {
    final start = alarmTime.subtract(before);
    final end = alarmTime.add(after);
    return now.isAfter(start) && now.isBefore(end);
  }
}
