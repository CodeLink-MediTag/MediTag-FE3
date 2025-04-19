class SelectionData {
  final String? medicineName;
  final String? note;
  final String? imagePath;
  final DateTime? startDate;
  final int? days;
  final String? timeGroup;
  final List<String>? selectedTimes;

  const SelectionData({
    this.medicineName,
    this.note,
    this.imagePath,
    this.startDate,
    this.days,
    this.timeGroup,
    this.selectedTimes,
  });

  SelectionData copyWith({
    String? medicineName,
    String? note,
    String? imagePath,
    DateTime? startDate,
    int? days,
    String? timeGroup,
    List<String>? selectedTimes,
  }) {
    return SelectionData(
      medicineName: medicineName ?? this.medicineName,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      startDate: startDate ?? this.startDate,
      days: days ?? this.days,
      timeGroup: timeGroup ?? this.timeGroup,
      selectedTimes: selectedTimes ?? this.selectedTimes,
    );
  }

  @override
  String toString() {
    return 'SelectionData(medicineName: \$medicineName, note: \$note, imagePath: \$imagePath, startDate: \$startDate, days: \$days, timeGroup: \$timeGroup, selectedTimes: \$selectedTimes)';
  }
}