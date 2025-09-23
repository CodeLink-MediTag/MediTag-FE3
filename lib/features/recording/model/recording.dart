class Recording {
  final String title;
  final DateTime recordingTime;
  final String recordingFile;
  final int id;

  Recording({
    required this.title,
    required this.recordingTime,
    required this.recordingFile,
    required this.id
  });

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      title: json['title'],
      recordingTime: DateTime.parse(json['recordingTime']),
      recordingFile: json['recordingFile'],
      id: json['id']
    );
  }
}
