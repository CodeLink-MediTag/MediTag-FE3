import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medife/ip/ip_address.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medife/components/custom_app_bar.dart'; // 커스텀 앱바 경로 맞게 수정

// calendar.dart 를 import 해야 할 때는
import 'package:medife/features/calendar/calendar.dart' hide Medicine, Alarm;

import '../../ip/ip_address.dart';


class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? token;
  List<Medicine> selectedMedicines = [];
  Set<DateTime> medicationDays = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });

    fetchMedicinesForDate(_selectedDay!);
    fetchMedicationDays();
  }

  Future<void> fetchMedicinesForDate(DateTime date) async {
    if (token == null) return;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      final response = await http.get(
        Uri.parse('http://$ipAddress:8080/api/medicines?date=$formattedDate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Medicine> fetched = (data['medicines'] as List)
            .map((m) => Medicine.fromJson(m))
            .toList();
        setState(() {
          selectedMedicines = fetched;
        });
      } else {
        setState(() {
          selectedMedicines = [];
        });
      }
    } catch (e) {
      print("에러 발생: $e");
    }
  }

  Future<void> fetchMedicationDays() async {
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/calendar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dates = json.decode(response.body);
        Set<DateTime> parsedDates =
        dates.map((d) => DateTime.parse(d)).toSet();
        setState(() {
          medicationDays = parsedDates;
        });
      }
    } catch (e) {
      print("회색 점 날짜 불러오기 실패: $e");
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return medicationDays.any((d) => isSameDay(d, day)) ? ['복약 있음'] : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '복약기록 캘린더'),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              fetchMedicinesForDate(selectedDay);
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration:
              BoxDecoration(color: Colors.pink[200], shape: BoxShape.circle),
              selectedDecoration:
              const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              markerDecoration:
              const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(
                titleCentered: true, formatButtonVisible: false),
          ),

          const SizedBox(height: 20),
          const Text("약 목록",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

          Expanded(
            child: selectedMedicines.isEmpty
                ? const Center(child: Text("선택 날짜에 복용 약이 없어요"))
                : ListView.builder(
                itemCount: selectedMedicines.length,
                itemBuilder: (context, index) {
                  final medicine = selectedMedicines[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(medicine.medicineName,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          ...medicine.alarms.map((alarm) {
                            String time = DateFormat('HH:mm')
                                .format(alarm.alarmTime);
                            return Row(
                              children: [
                                Text(time,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 12),
                                Text(
                                  alarm.taking ? "복용" : "미복용",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: alarm.taking
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          }).toList()
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

// 모델 클래스
class Medicine {
  final String medicineName;
  final List<Alarm> alarms;

  Medicine({required this.medicineName, required this.alarms});

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medicineName: json['medicineName'],
      alarms: (json['alarms'] as List)
          .map((a) => Alarm.fromJson(a))
          .toList(),
    );
  }
}

class Alarm {
  final DateTime alarmTime;
  final bool taking;

  Alarm({required this.alarmTime, required this.taking});

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      alarmTime: DateTime.parse(json['alarmTime']),
      taking: json['taking'],
    );
  }
}
