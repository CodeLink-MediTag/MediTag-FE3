import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medife/features/eatlist/model/medicine.dart';
import 'package:medife/ip/ip_address.dart';

class EatListRepository{
  Future<List<Medicine>> fetchMedicines(String date, String token) async {
    final uri = Uri.parse("http://$ipAddress:8080/api/medicines?date=$date");
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List medicinesJson = decoded['medicines'];
      final re = medicinesJson.map((m) => Medicine.fromJson(m)).toList();
      return re;
    } else {
      throw Exception("Failed to load medicines");
    }
  }

  Future<void> patchDosageTime({
    required int medicineId,
    required String time, // dosageTime 또는 alarmTime으로 사용됨
    required String date,
    required String token,
    required bool prescribed, // 처방약 여부
  }) async {
    final baseUrl = 'http://$ipAddress:8080'; // 실제 서버 주소로 교체하세요

    // 시간 파라미터 키 결정
    final timeKey = prescribed ? 'dosageTime' : 'alarmTime';

    final uri = Uri.parse('$baseUrl/api/medicines/$medicineId/alarms/taking')
        .replace(queryParameters: {
      timeKey: time,
      'date': date,
    });

    try {
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('알람 정보 수정 성공');
      } else {
        print('오류 발생: ${response.statusCode}');
        print('응답 본문: ${response.body}');
      }
    } catch (e) {
      print('요청 실패: $e');
    }
  }


}
