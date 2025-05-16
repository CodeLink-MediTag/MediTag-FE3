class MediStartSelectionData {
  final String? name;
  final String? characteristic;
  final String? startDate;
  final int? duration;
  final int? frequency;
  final String? imageUrl;
  final bool? prescribed;
  final List<String>? dosageTimes;
  final List<String>? alarmTimes;

  const MediStartSelectionData({
    this.name,
    this.characteristic,
    this.startDate,
    this.duration,
    this.frequency,
    this.imageUrl,
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
      prescribed: prescribed ?? this.prescribed,
      dosageTimes: dosageTimes ?? this.dosageTimes,
      alarmTimes: alarmTimes ?? this.alarmTimes,
    );
  }

  @override
  String toString() {
    return 'MediStartSelectionData(name: \$name, characteristic: \$characteristic, startDate: \$startDate, duration: \$duration, frequency: \$frequency, imageUrl: \$imageUrl, prescribed: \$prescribed, dosageTimes: \$dosageTimes, alarmTimes: \$alarmTimes)';
  }
}
