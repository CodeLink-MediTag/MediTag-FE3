// medimain_medicine_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../ip/ip_address.dart';
import '../model/medimain_medicine.dart';
import '../model/medimain_alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class MedicineRepository {
  final String baseUrl = 'http://$ipAddress/api/medicines';

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

  /// 즐겨찾기 토글 (기존 방식 유지)
  Future<void> toggleFavorite(String token, Medicine med) async {
    final uri = Uri.parse('http://$ipAddress/favorite'); // 백엔드가 /favorite 에 매핑돼 있음
    final req = http.Request('PUT', uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..body = jsonEncode({
        'medicineId': med.medicineId,
      });

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception('즐겨찾기 토글 실패: ${res.statusCode} ${res.body}');
    }
  }

  /// 복용 상태를 서버에 반영 (PATCH)
  Future<void> patchTaking({
    required String token,
    required int medicineId,
    required String alarmIso, // alarmTime ISO string
    required String date, // yyyy-MM-dd
    required bool taking,
  }) async {
    // Endpoint in BE: PATCH /api/medicines/{medicineId}/alarms/taking?alarmTime=...&date=...
    final uri = Uri.parse('$baseUrl/$medicineId/alarms/taking').replace(queryParameters: {
      'alarmTime': alarmIso,
      'date': date,
    });

    final res = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'taking': taking}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('patch taking 실패: ${res.statusCode} ${res.body}');
    }
  }
}
