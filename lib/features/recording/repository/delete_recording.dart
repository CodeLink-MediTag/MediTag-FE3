import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../ip/ip_address.dart';
import '../model/recording.dart';

Future<void> deleteRecording(String id) async {
  // SharedPreferences에서 accessToken 불러오기
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    throw Exception('Access token이 없습니다.');
  }

  // API 호출
  final url = Uri.parse('http://$ipAddress/api/records/$id');
  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('녹음 삭제 실패: ${response.statusCode}');
  }
}
