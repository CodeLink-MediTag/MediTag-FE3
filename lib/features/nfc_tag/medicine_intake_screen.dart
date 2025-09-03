import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../ip/ip_address.dart';

class MedicineIntakeScreen extends StatefulWidget {
  final String timeLabel; // "아침", "점심", "저녁"
  final String targetTime; // "08:00:00", "12:00:00", "18:00:00"

  MedicineIntakeScreen({
    required this.timeLabel,
    required this.targetTime,
    Key? key,
  }) : super(key: key);

  @override
  _MedicineIntakeScreenState createState() => _MedicineIntakeScreenState();
}

class _MedicineIntakeScreenState extends State<MedicineIntakeScreen> {
  bool _loading = true;
  String? _message;
  bool? _alreadyTaken;
  bool _showButton = false;
  int? _medicineId;
  String? _alarmTime;
  bool? _prescribed;

  @override
  void initState() {
    super.initState();
    _checkPrescription();
  }

  Future<void> _checkPrescription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) throw Exception("토큰 없음");
      final today = DateTime.now();
      final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      final uri = Uri.parse("http://$ipAddress:8080/api/medicines?date=$dateStr");
      final response = await http.get(uri, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final medicines = data["medicines"] as List<dynamic>;
        final prescribed = medicines.where((m) => m["prescribed"] == true).toList();
        if (prescribed.isEmpty) {
          setState(() {
            _message = "처방약이 없습니다.";
            _showButton = false;
            _loading = false;
          });
          return;
        }
        final medicine = prescribed.first;
        final alarms = medicine["alarms"] as List<dynamic>;
        final alarm = alarms.firstWhere(
              (a) => a["alarmTime"].toString().contains(widget.targetTime),
          orElse: () => null,
        );
        if (alarm == null) {
          setState(() {
            _message = "처방약에 ${widget.timeLabel}약이 없습니다.";
            _showButton = false;
            _loading = false;
          });
          return;
        }
        final taking = alarm["taking"] as bool;
        _medicineId = medicine["medicineId"];
        _alarmTime = alarm["alarmTime"];
        _prescribed = medicine["prescribed"];
        setState(() {
          if (taking) {
            _message = "이미 복용했습니다 ✅";
            _alreadyTaken = true;
            _showButton = true;
          } else {
            _message = null;
            _alreadyTaken = false;
            _showButton = true;
          }
          _loading = false;
        });
      } else {
        throw Exception("서버 오류: ${response.body}");
      }
    } catch (e) {
      setState(() {
        _message = "에러 발생: $e";
        _showButton = false;
        _loading = false;
      });
    }
  }

  Future<void> _takeMedicine() async {
    if (_medicineId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    await patchDosageTime(
      medicineId: _medicineId!,
      date: dateStr,
      token: token,
      timeLabel: widget.timeLabel, // 필수로 전달!
    );
    setState(() {
      _alreadyTaken = true;
      _message = "복용 완료 ✅";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.timeLabel} 약 복용")),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_message != null) ...[
              Text(_message!, style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
            ],
            if (_showButton)
              ElevatedButton(
                onPressed: (_alreadyTaken == true) ? null : _takeMedicine,
                child: Text(_alreadyTaken == true
                    ? "이미 복용했습니다 ✅"
                    : "복용했어요 ✅"),
              ),
          ],
        ),
      ),
    );
  }
}

// PATCH 함수: 복용시간을 매번 전달
Future<void> patchDosageTime({
  required int medicineId,
  required String date,
  required String token,
  required String timeLabel, // "아침", "점심", "저녁"
}) async {
  final baseUrl = 'http://$ipAddress:8080';
  final uri = Uri.parse('$baseUrl/api/medicines/$medicineId/alarms/taking')
      .replace(queryParameters: {
    'dosageTime': timeLabel,
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
      print('복용 처리 성공');
    } else {
      print('오류 발생: ${response.statusCode}');
      print('응답 본문: ${response.body}');
    }
  } catch (e) {
    print('요청 실패: $e');
  }
}
