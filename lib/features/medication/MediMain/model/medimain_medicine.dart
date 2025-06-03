import 'medimain_alarm.dart';

class Medicine {
  final int medicineId;
  final String medicineName;
  final String characteristic;
  final String? imageUrl;
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
    required this.prescribed,
    required this.duration,
    required this.frequency,
    required this.alarms,
    this.isFavorite = false,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medicineId: json['medicineId'] as int,
      medicineName: (json['medicineName'] as String?) ?? '이름 없음',
      characteristic: (json['characteristic'] as String?) ?? '',
      imageUrl: json['imageUrl'] as String?,

      // 처리약 여부
      prescribed: json['prescribed'] as bool,

      // 반드시 여기서 서버 응답의 duration, frequency를 읽어서 넘겨줘야 함
      duration: (json['duration'] as int?) ?? 0,
      // 서버에 저장된 duration
      frequency: json['frequency'] as int?,
      // 서버에 저장된 frequency

      // alarms는 기존 로직 유지
      alarms: (json['alarms'] as List<dynamic>)
          .map((a) => Alarm.fromJson(a as Map<String, dynamic>))
          .toList(),
      isFavorite: (json['isFavorite'] as bool?) ?? false,
    );
  }
}