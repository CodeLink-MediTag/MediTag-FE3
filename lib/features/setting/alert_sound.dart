// lib/features/setting/alert_sound.dart
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class AlertSound extends StatefulWidget {
  const AlertSound({Key? key}) : super(key: key);

  @override
  State<AlertSound> createState() => _AlertSoundState();
}

class _AlertSoundState extends State<AlertSound> {
  final AudioPlayer _player = AudioPlayer();
  String? _selected; // ex: 'alert1.mp3'
  bool _isPlaying = false;

  // 사운드 목록 (label + 파일명)
  final List<Map<String, String>> _sounds = [
    {'label': '알림음 1', 'file': 'alert1.mp3'},
    {'label': '알림음 2', 'file': 'alert2.mp3'},
    {'label': '알림음 3', 'file': 'alert3.mp3'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelected();

    // 플레이어 상태 리스너
    _player.onPlayerComplete.listen((_) {
      setState(() => _isPlaying = false);
    });
    _player.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadSelected() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selected = prefs.getString('alert_sound') ?? _sounds[0]['file'];
    });
  }

  Future<void> _saveSelected(String file) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alert_sound', file);
    setState(() => _selected = file);
  }

  /// 안전한 에셋 재생:
  /// 1) AssetSource('assets/sounds/xxx') 시도
  /// 2) AssetSource('sounds/xxx') 시도
  /// 3) rootBundle.load('assets/sounds/xxx') 후 BytesSource 재생
  Future<void> _playAsset(String file) async {
    try {
      // 중복 재생 방지
      await _player.stop();

      // 1) try 'assets/sounds/xxx' (일부 환경에서 절대 경로가 필요)
      try {
        await _player.play(AssetSource('assets/sounds/$file'));
        return;
      } catch (e) {
        // ignore and fallback
        // ignore: avoid_print
        print('AssetSource("assets/...") failed: $e');
      }

      // 2) try 'sounds/xxx' (경우에 따라 이게 맞음)
      try {
        await _player.play(AssetSource('sounds/$file'));
        return;
      } catch (e) {
        // ignore and fallback
        // ignore: avoid_print
        print('AssetSource("sounds/...") failed: $e');
      }

      // 3) rootBundle -> BytesSource (최후 수단)
      try {
        final ByteData bd = await rootBundle.load('assets/sounds/$file');
        final Uint8List bytes = bd.buffer.asUint8List();
        await _player.play(BytesSource(bytes));
        return;
      } catch (e) {
        // ignore and let outer catch handle
        // ignore: avoid_print
        print('rootBundle.load fallback failed: $e');
        rethrow;
      }
    } catch (e, st) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('소리를 재생할 수 없습니다: ${e.toString()}')),
        );
      }
      // debug print
      // ignore: avoid_print
      print('Audio play final error: $e\n$st');
    }
  }

  Future<void> _stop() async {
    try {
      await _player.stop();
      setState(() => _isPlaying = false);
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림음'),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: _sounds.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, idx) {
          final item = _sounds[idx];
          final file = item['file']!;
          final label = item['label']!;
          final selected = file == _selected;
          final playingThis = _isPlaying && (file == _selected);

          return ListTile(
            leading: IconButton(
              icon: Icon(
                playingThis ? Icons.stop_circle : Icons.play_circle_fill,
                color: Colors.blue,
                size: 32,
              ),
              onPressed: () async {
                if (playingThis) {
                  await _stop();
                } else {
                  await _playAsset(file);
                }
              },
            ),
            title: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            subtitle: Text(file, style: const TextStyle(color: Colors.black45)),
            trailing: Radio<String>(
              value: file,
              groupValue: _selected,
              onChanged: (v) async {
                if (v == null) return;
                await _saveSelected(v);
                await _playAsset(v);
              },
            ),
            onTap: () async {
              await _saveSelected(file);
              await _playAsset(file);
            },
          );
        },
      ),
    );
  }
}
