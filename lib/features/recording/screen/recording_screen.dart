import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/features/recording/screen/recording_list_screen.dart';
import 'package:medife/ip/ip_address.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final Record _record = Record();
  bool _isRecording = false;
  String _recordFilePath = '';
  String _title = '';

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      await _record.start();
      setState(() {
        _isRecording = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마이크 권한이 필요합니다!')),
      );
    }
  }

  Future<void> _stopRecording() async {
    final path = await _record.stop();
    setState(() {
      _isRecording = false;
      _recordFilePath = path ?? '';
    });
    if (path != null) {
      await _sendToServer(path);
    }
  }

  Future<void> _sendToServer(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      _showMessage("❌ 토큰이 없습니다. 로그인 상태를 확인해주세요.");
      return;
    }

    final jsonMap = {
      "title": _title,
      "recordingTime": DateTime.now().toIso8601String(),
      "recordingFile": p.basename(filePath),
    };

    try {
      final formData = FormData.fromMap({
        "data": jsonEncode(jsonMap),
        "file": await MultipartFile.fromFile(
          filePath,
          filename: p.basename(filePath),
          contentType: MediaType('audio', 'mpeg'),
        ),
      });

      final dio = Dio();
      final url = 'http://$ipAddress:8080/api/records';
      final response = await dio.post(
        url,
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage("✅ 녹음 파일이 저장되었습니다");
      } else {
        _showMessage("⚠️ 서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("❌ 전송 중 오류가 발생했습니다");
    }
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formattedTime() {
    final now = DateTime.now();
    return '${now.year}.${now.month}.${now.day}\n${DateFormat('a hh:mm', 'ko_KR').format(now)} 녹음';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final startTime = _formattedTime();

    // container color: primaryContainer 선호, 없으면 primary의 투명 색 사용
    final bigPanelColor = cs.primaryContainer ?? cs.primary.withOpacity(0.12);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppBar(title: '주의사항 녹음'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bigPanelColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black26.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRecording ? '🎙️ 녹음중' : startTime,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    decoration: InputDecoration(
                      labelText: '약 이름을 입력하세요',
                      labelStyle: theme.textTheme.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
                      prefixIcon: Icon(Icons.medication, color: cs.primary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.primary, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _title = value;
                      });
                    },
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _toggleRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.red : cs.primary,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size(double.infinity, 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    child: Text(_isRecording ? '녹음 끝내기' : '녹음 시작', style: theme.textTheme.titleLarge?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecordingListScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.secondary,
                      foregroundColor: cs.onSecondary,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    child: Text('녹음 파일 목록', style: theme.textTheme.titleMedium?.copyWith(color: cs.onSecondary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
