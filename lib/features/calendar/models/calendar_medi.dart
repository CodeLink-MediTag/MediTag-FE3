class Medicine {
  final String name;
  final List<Alarm> alarms;
  Medicine({required this.name, required this.alarms});
  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    name: json['medicineName'],
    alarms: (json['alarms'] as List)
        .map((a) => Alarm.fromJson(a))
        .toList(),
  );
}

class Alarm {
  final DateTime time;
  final bool taken;
  Alarm({required this.time, required this.taken});
  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    time: DateTime.parse(json['alarmTime']),
    taken: json['taking'],
  );
}