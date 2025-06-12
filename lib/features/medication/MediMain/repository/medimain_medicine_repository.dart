import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../ip/ip_address.dart';
import '../model/medimain_medicine.dart';
import '../model/medimain_alarm.dart';
import 'package:flutter/foundation.dart';


class MedicineRepository {
  final String baseUrl = 'http://$ipAddress:8080/api/medicines';

  Future<List<Medicine>> fetchMedicines(String token, String date) async {
    final res = await http.get(
      Uri.parse('$baseUrl?date=$date'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) throw Exception('fetch error');

    final List data = json.decode(res.body)['medicines'];
    return data.map((e) => Medicine.fromJson(e)).toList();
  }

  /// 토큰과 Medicine 객체를 받아서 서버에 즐겨찾기 상태를 토글합니다.
  Future<void> toggleFavorite(String token, Medicine med) async {
    final uri = Uri.parse('$baseUrl/favorite');
    // PATCH 요청을 직접 생성
    final req = http.Request('PATCH', uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
    // bodyBytes에 UTF-8 인코딩된 JSON 바이트를 그대로 넣으면
    // http 패키지가 charset을 자동으로 추가하지 않습니다.
      ..bodyBytes = utf8.encode(jsonEncode({
        'medicineName': med.medicineName,
        'favorite': med.isFavorite,
      }));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception('즐겨찾기 토글 실패: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> updateTaking(String token, Medicine med, Alarm alarm) async {
    await http.post(
      Uri.parse('$baseUrl/taking'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'medicineName': med.medicineName,
        'alarmTime': alarm.alarmTime.toIso8601String(),
        'taking': alarm.taking,
      }),
    );
  }
}

