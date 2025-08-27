class Recording {
  final String title;
  final DateTime recordingTime;
  final String recordingFile;

  Recording({
    required this.title,
    required this.recordingTime,
    required this.recordingFile,
  });

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      title: json['title'],
      recordingTime: DateTime.parse(json['recordingTime']),
      recordingFile: json['recordingFile'],
    );
  }
}
