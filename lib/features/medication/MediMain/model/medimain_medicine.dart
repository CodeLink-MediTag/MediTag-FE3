import 'medimain_alarm.dart';

class Medicine {
  final String medicineName;
  final String characteristic;
  final String? imageUrl;
  final bool prescribed;
  final List<Alarm> alarms;
  bool isFavorite;

  Medicine({
    required this.medicineName,
    required this.characteristic,
    this.imageUrl,
    required this.prescribed,
    required this.alarms,
    this.isFavorite = false,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      // null이 넘어와도 빈 문자열이나 '이름 없음'으로 치환
      medicineName: (json['medicineName'] as String?) ?? '이름 없음',
      characteristic: (json['characteristic'] as String?) ?? '',
      imageUrl: json['imageUrl'] as String?,
      prescribed: json['prescribed'] as bool,
      alarms: (json['alarms'] as List)
          .map((a) => Alarm.fromJson(a))
          .toList(),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}

