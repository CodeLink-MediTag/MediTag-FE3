import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:medife/components/custom_app_bar.dart';
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
  int? playingIndex;

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
      await _audioPlayer.stop();
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(title: '주의사항 녹음'),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<List<Recording>>(
        future: recordingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text("오류: ${snapshot.error}", style: theme.textTheme.bodyLarge));
          }
          final recordings = snapshot.data ?? [];
          if (recordings.isEmpty) {
            return Center(child: Text('등록된 녹음이 없습니다.', style: theme.textTheme.bodyLarge));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: recordings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rec = recordings[index];
              return Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26.withOpacity(0.02), blurRadius: 4)],
                ),
                child: ListTile(
                  title: Text(rec.title, style: theme.textTheme.titleMedium),
                  subtitle: Text(
                    rec.recordingTime.toLocal().toString(),
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      playingIndex == index ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: cs.primary,
                      size: 28,
                    ),
                    onPressed: () => _togglePlay(rec.recordingFile, index),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
