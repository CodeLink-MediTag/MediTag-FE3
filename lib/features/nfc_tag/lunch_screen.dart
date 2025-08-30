import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ip/ip_address.dart';

class LunchScreen extends StatefulWidget {
  @override
  _LunchScreenState createState() => _LunchScreenState();
}

class _LunchScreenState extends State<LunchScreen> {
  bool _loading = true;
  String? _message;     // 사용자에게 보여줄 메시지
  bool? _alreadyTaken;  // 이미 복용했는지
  bool _showButton = false; // 버튼 표시 여부

  final String _targetTime = "12:00:00"; // 점심 시간 고정

  @override
  void initState() {
    super.initState();
    _checkPrescription();
  }

  Future<void> _checkPrescription() async {
    try {
      // 1. 토큰 가져오기
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) throw Exception("토큰 없음");

      // 2. 오늘 날짜 yyyy-MM-dd
      final today = DateTime.now();
      final dateStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // 3. 서버 요청
      final uri = Uri.parse("http://$ipAddress:8080/api/medicines?date=$dateStr");
      final response = await http.get(uri, headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final medicines = data["medicines"] as List<dynamic>;
        final prescribed = medicines.where((m) => m["prescribed"] == true).toList();

        if (prescribed.isEmpty) {
          // 처방약 없음
          setState(() {
            _message = "처방약이 없습니다.";
            _showButton = false;
            _loading = false;
          });
          return;
        }

        // 4. 처방약은 1개라고 했으니 첫 번째만 사용
        final alarms = prescribed.first["alarms"] as List<dynamic>;

        // 5. targetTime에 해당하는 알람 찾기 (점심 == 12:00:00)
        final alarm = alarms.firstWhere(
              (a) => a["alarmTime"].toString().contains(_targetTime),
          orElse: () => null,
        );

        if (alarm == null) {
          // 해당 시간대 약 없음
          setState(() {
            _message = "처방약에 점심약이 없습니다.";
            _showButton = false;
            _loading = false;
          });
          return;
        }

        final taking = alarm["taking"] as bool;

        setState(() {
          if (taking) {
            _message = "이미 복용했습니다 ✅";
            _alreadyTaken = true;
            _showButton = true; // 버튼은 보이지만 disable
          } else {
            _message = null; // 메시지 대신 버튼만 보여줌
            _alreadyTaken = false;
            _showButton = true;
          }
          _loading = false;
        });
      } else {
        throw Exception("서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _message = "에러 발생: $e";
        _showButton = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("점심 약 복용")),
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
                onPressed: (_alreadyTaken == true)
                    ? null
                    : () {
                  // TODO: 복용 여부 변경 API 호출 (다음 단계에서)
                  Navigator.pop(context);
                },
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
