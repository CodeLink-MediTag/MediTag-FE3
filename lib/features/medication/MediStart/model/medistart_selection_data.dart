import 'dart:typed_data';

class MediStartSelectionData {
  final String? name;
  final String? characteristic;
  final String? startDate;
  final int? duration;
  final int? frequency;
  final String? imagePath;       // 모바일에서만 사용
  final Uint8List? imageBytes;   // 웹에서만 사용
  final bool? prescribed;
  final List<String>? dosageTimes;
  final List<String>? alarmTimes;

  const MediStartSelectionData({
    this.name,
    this.characteristic,
    this.startDate,
    this.duration,
    this.frequency,
    this.imagePath,
    this.imageBytes,
    this.prescribed,
    this.dosageTimes,
    this.alarmTimes,
  });

  MediStartSelectionData copyWith({
    String? name,
    String? characteristic,
    String? startDate,
    int? duration,
    int? frequency,
    String? imagePath,
    Uint8List? imageBytes,
    bool? prescribed,
    List<String>? dosageTimes,
    List<String>? alarmTimes,
  }) {
    return MediStartSelectionData(
      name: name ?? this.name,
      characteristic: characteristic ?? this.characteristic,
      startDate: startDate ?? this.startDate,
      duration: duration ?? this.duration,
      frequency: frequency ?? this.frequency,
      imagePath:      imagePath      ?? this.imagePath,
      imageBytes:     imageBytes     ?? this.imageBytes,
      prescribed: prescribed ?? this.prescribed,
      dosageTimes: dosageTimes ?? this.dosageTimes,
      alarmTimes: alarmTimes ?? this.alarmTimes,
    );
  }

  @override
  String toString() {
    return 'MediStartSelectionData('
        'name: $name, '
        'characteristic: $characteristic, '
        'startDate: $startDate, '
        'duration: $duration, '
        'frequency: $frequency, '
        'prescribed: $prescribed, '
        'dosageTimes: $dosageTimes, '
        'alarmTimes: $alarmTimes, '
        'imagePath: $imagePath, '
        'imageBytes: ${imageBytes != null ? '${imageBytes!.length} bytes' : 'null'}'
        ')';
  }
}
