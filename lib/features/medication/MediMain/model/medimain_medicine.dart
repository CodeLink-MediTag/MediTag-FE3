// lib/features/medication/MediMain/model/medimain_medicine.dart
import 'medimain_alarm.dart';

class Medicine {
  final int medicineId;
  final String medicineName;
  final String characteristic;
  final String? imageUrl;
  final bool isPrescription;
  final bool prescribed;
  final int duration;
  final int? frequency;
  final List<Alarm> alarms;
  bool isFavorite;

  Medicine({
    required this.medicineId,
    required this.medicineName,
    required this.characteristic,
    this.imageUrl,
    required this.isPrescription,
    required this.prescribed,
    required this.duration,
    required this.frequency,
    required this.alarms,
    this.isFavorite = false,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    final alarmsJson = (json['alarms'] as List<dynamic>?) ?? [];
    return Medicine(
      medicineId: json['medicineId'] as int,
      medicineName: (json['medicineName'] as String?) ?? '이름 없음',
      characteristic: (json['characteristic'] as String?) ?? '',
      imageUrl: json['imageUrl'] as String?,
      prescribed: (json['prescribed'] as bool?) ?? false,
      isPrescription: (json['prescribed'] as bool?) ?? false,
      duration: (json['duration'] as int?) ?? 0,
      frequency: json['frequency'] as int?,
      alarms: alarmsJson.map((a) => Alarm.fromJson(a as Map<String, dynamic>)).toList(),
      isFavorite: (json['isFavorite'] as bool?) ?? false,
    );
  }

  /// 현재 시간(now)을 기준으로 가장 "유효한" 알람을 찾음:
  /// - 먼저 now와 윈도우(-1h/+1h)에 들어있는 알람을 반환
  /// - 없으면 (now 기준) 다음으로 올 알람(미래의 가장 가까운 알람)을 반환
  /// - 없으면 null
  Alarm? findRelevantAlarm(DateTime now, {Duration before = const Duration(hours: 1), Duration after = const Duration(hours: 1)}) {
    if (alarms.isEmpty) return null;

    // 1) 윈도우 안의 알람(우선)
    for (final a in alarms) {
      if (a.isWithinWindow(now, before: before, after: after)) return a;
    }

    // 2) 미래의 가장 가까운 알람
    final futureAlarms = alarms.where((a) => a.alarmTime.isAfter(now)).toList();
    if (futureAlarms.isNotEmpty) {
      futureAlarms.sort((x, y) => x.alarmTime.compareTo(y.alarmTime));
      return futureAlarms.first;
    }

    // 3) 없으면 null
    return null;
  }
}
