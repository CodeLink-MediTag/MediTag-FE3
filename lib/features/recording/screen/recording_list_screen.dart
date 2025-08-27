import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../components/custom_app_bar.dart';
import '../model/recording.dart';
import '../repository/fetch_recordings.dart';

class RecordingListScreen extends StatefulWidget {
  const RecordingListScreen({super.key});

  @override
  State<RecordingListScreen> createState() => _RecordingListScreenState();
}

class _RecordingListScreenState extends State<RecordingListScreen> {
  late Future<List<Recording>> recordingsFuture;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? playingIndex; // 현재 재생중인 인덱스

  @override
  void initState() {
    super.initState();
    recordingsFuture = fetchRecordings();
  }

  Future<void> _togglePlay(String url, int index) async {
    if (playingIndex == index) {
      await _audioPlayer.pause();
      setState(() => playingIndex = null);
    } else {
      await _audioPlayer.stop(); // 다른 재생 중인 거 멈춤
      await _audioPlayer.play(UrlSource(url));
      setState(() => playingIndex = index);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:const CustomAppBar(title: '주의사항 녹음'),
      body: FutureBuilder<List<Recording>>(
        future: recordingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("오류: ${snapshot.error}"));
          }
          final recordings = snapshot.data!;
          return ListView.builder(
            itemCount: recordings.length,
            itemBuilder: (context, index) {
              final recording = recordings[index];
              return ListTile(
                title: Text(recording.title),
                subtitle: Text(
                  recording.recordingTime.toLocal().toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: Icon(
                    playingIndex == index ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () =>
                      _togglePlay(recording.recordingFile, index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
