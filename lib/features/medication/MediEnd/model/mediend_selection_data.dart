


class MediEndSelectionData {
  final String? name;
  final String? characteristic;
  final String  startDate;
  final int     duration;
  final int     frequency;
  final String? imageUrl;
  final bool    prescribed;
  final List<String> dosageTimes;
  final List<String> alarmTimes;

  const MediEndSelectionData({
    this.name,
    this.characteristic,
    required this.startDate,
    required this.duration,
    required this.frequency,
    this.imageUrl,
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
      prescribed: prescribed ?? this.prescribed,
      dosageTimes: dosageTimes ?? this.dosageTimes,
      alarmTimes: alarmTimes ?? this.alarmTimes,
    );
  }

  @override
  String toString() {
    return 'MediEndSelectionData(name: \$name, characteristic: \$characteristic, startDate: \$startDate, duration: \$duration, frequency: \$frequency, imageUrl: \$imageUrl, prescribed: \$prescribed, dosageTimes: \$dosageTimes, alarmTimes: \$alarmTimes)';
  }
}


