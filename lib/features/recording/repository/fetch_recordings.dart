import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../ip/ip_address.dart';
import '../model/recording.dart';

Future<List<Recording>> fetchRecordings() async {
  // SharedPreferences에서 accessToken 불러오기
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    throw Exception('Access token이 없습니다.');
  }

  // API 호출
  final url = Uri.parse('http://$ipAddress/api/records'); // 도메인 수정
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
    return jsonList.map((e) => Recording.fromJson(e)).toList();
  } else {
    throw Exception('녹음 목록 불러오기 실패: ${response.statusCode}');
  }
}
