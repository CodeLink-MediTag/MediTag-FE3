import 'package:medife/features/eatlist/model/alarm.dart';

class Medicine {
  final int medicineId;
  final String name;
  final String characteristic;
  final String? imageUrl;
  final bool prescribed;
  final List<Alarm> alarms;

  Medicine({
    required this.medicineId,
    required this.name,
    required this.characteristic,
    required this.imageUrl,
    required this.prescribed,
    required this.alarms,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medicineId: json['medicineId'],
      name: json['medicineName'] ?? '',
      characteristic: json['characteristic'] ?? '',
      imageUrl: json['imageUrl'], // null 허용이므로 그대로 가능
      prescribed: json['prescribed'] ?? false,
      alarms: (json['alarms'] as List?)?.map((alarm) => Alarm.fromJson(alarm)).toList() ?? [],
    );
  }
}