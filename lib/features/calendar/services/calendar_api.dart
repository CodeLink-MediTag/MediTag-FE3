import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/calendar_medi.dart';
import '../../../ip/ip_address.dart';

class CalendarApi {
  static String? _token;

  static Future<void> loadToken() async {
    final p = await SharedPreferences.getInstance();
    _token = p.getString('accessToken');
  }

  static Future<List<Medicine>> fetchMedicinesForDate(DateTime d) async {
    if (_token == null) return [];
    final date = d.toIso8601String().substring(0, 10);
    final res = await http.get(
      Uri.parse('http://$ipAddress/api/medicines?date=$date'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode != 200) return [];
    final data = json.decode(res.body)['medicines'] as List;
    return data.map((m) => Medicine.fromJson(m)).toList();
  }

  static Future<Set<DateTime>> fetchMedicationDays() async {
    if (_token == null) return {};
    final res = await http.get(
      Uri.parse('http://$ipAddress/api/calendar'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode != 200) return {};
    final dates = json.decode(res.body) as List;
    return dates.map((d) => DateTime.parse(d)).toSet();
  }
}