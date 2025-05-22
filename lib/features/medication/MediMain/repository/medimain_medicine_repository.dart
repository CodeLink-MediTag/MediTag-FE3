import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/medimain_medicine.dart';
import '../model/medimain_alarm.dart';
import 'package:flutter/foundation.dart';


class MedicineRepository {
  final String baseUrl = 'http://$ipAdress:8080/api/medicines';

  Future<List<Medicine>> fetchMedicines(String token, String date) async {
    final res = await http.get(
      Uri.parse('$baseUrl?date=$date'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) throw Exception('fetch error');

    debugPrint('🏥 fetchMedicines() response body:\n${res.body}');

    final List data = json.decode(res.body)['medicines'];
    return data.map((e) => Medicine.fromJson(e)).toList();
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

  Future<void> toggleFavorite(String token, Medicine med) async {
    await http.post(
      Uri.parse('$baseUrl/favorite'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'medicineName': med.medicineName,
        'favorite': med.isFavorite,
      }),
    );
  }
}


