import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medife/ip/ip_address.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/custom_app_bar.dart';
import 'recordlist.dart';

class RecordingPop2 extends StatefulWidget {
  const RecordingPop2({super.key});

  @override
  State<RecordingPop2> createState() => _RecordingPop2State();
}

class _RecordingPop2State extends State<RecordingPop2> {
  final Record _record = Record();
  bool _isRecording = false;
  String _recordFilePath = '';

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
    final path = await _record.stop(); // 경로 반환됨

    setState(() {
      _isRecording = false;
      _recordFilePath = path ?? '';
    });

    if (path != null) {
      await _sendToServer(path);
    }
  }

  Future<void> _sendToServer(String filePath) async {
    String url = 'http://$ipAddress:8080/api/records';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      _showMessage("❌ 토큰이 없습니다. 로그인 상태를 확인해주세요.");
      return;
    }

    final jsonMap = {
      "title": "테스트 녹음",
      "recordingTime": DateTime.now().toIso8601String(),
      "recordingFile": p.basename(filePath),
    };

    try {
      final formData = FormData.fromMap({
        "data": jsonEncode(jsonMap),
        "file": await MultipartFile.fromFile(
          filePath,
          filename: p.basename(filePath),
        ),
      });

      final dio = Dio();

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage("✅ 녹음 파일이 저장되었습니다");
      } else {
        _showMessage("⚠️ 서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ 오류 발생: $e');
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formattedTime() {
    final now = DateTime.now();
    return '${now.year}.${now.month}.${now.day}\n${DateFormat('a hh:mm', 'ko_KR').format(now)} 녹음';
  }

  @override
  Widget build(BuildContext context) {
    final startTime = _formattedTime();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          const CustomAppBar(title: '주의사항 녹음'),

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
                      color: const Color(0xFFA5C7FA),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRecording ? '🎙️ 녹음중' : startTime,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _toggleRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.red : const Color(0xFF547EE8),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(_isRecording ? '녹음 끝내기' : '녹음 시작'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecordList()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7D8FF7),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('녹음 파일 목록'),
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
