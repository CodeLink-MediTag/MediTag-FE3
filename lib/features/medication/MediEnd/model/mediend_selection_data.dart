import 'dart:typed_data';


class MediEndSelectionData {
  final String? name;
  final String? characteristic;
  final String  startDate;
  final int     duration;
  final int     frequency;
  final String? imagePath;
  final Uint8List? imageBytes;
  final bool    prescribed;
  final List<String> dosageTimes;
  final List<String> alarmTimes;

  const MediEndSelectionData({
    this.name,
    this.characteristic,
    required this.startDate,
    required this.duration,
    required this.frequency,
    this.imagePath,
    this.imageBytes,
    required this.prescribed,
    required this.dosageTimes,
    required this.alarmTimes,
  });

  MediEndSelectionData copyWith({
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
    return MediEndSelectionData(
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
    return 'MediEndSelectionData('
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
