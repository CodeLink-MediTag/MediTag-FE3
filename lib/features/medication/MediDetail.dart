import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medife/features/medication/MediEdit.dart';


class MediDetail extends StatefulWidget {
  @override
  _MediDetailState createState() => _MediDetailState();
}

class _MediDetailState extends State<MediDetail> {
  String medicationName = "처방약";
  DateTime startDate = DateTime.now();
  int duration = 7;
  String selectedTime = "아침";
  String selectedFrequency = "3번";
  TimeOfDay alarmTime = TimeOfDay.now();

  void _navigateToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediEdit(
          name: medicationName,
          startDate: startDate,
          duration: duration,
          selectedTime: selectedTime,
          selectedFrequency: selectedFrequency,
          alarmTime: alarmTime,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        medicationName = result['name'];
        startDate = result['startDate'];
        duration = result['duration'];
        selectedTime = result['selectedTime'];
        selectedFrequency = result['selectedFrequency'];
        alarmTime = result['alarmTime'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6), // 연한 회색 배경
      body: SingleChildScrollView( // 스크롤 가능하게 변경
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color(0xFF547EE8),
              padding: EdgeInsets.only(top: 37, bottom: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: (){
                        Navigator.pop(context); // 현재 화면 종료 (이전 화면으로 돌아감)
                      },
                    ),
                  ),
                  Center(
                    child: Text(
                      '상세 페이지',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFF547EE8), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleWithValue("약 이름", medicationName),
                    _buildTitleWithValue("복용 시작 날짜", DateFormat('yyyy-MM-dd').format(startDate)),
                    _buildTitleWithValue("복용 기간", "${duration}일"),
                    _buildTitleWithValue("복용 시간대", selectedTime),
                    _buildTitleWithValue("복용 주기", selectedFrequency),
                    _buildTitleWithValue("알림 시간", alarmTime.format(context)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20), // 버튼과 내용 간 간격 추가
            Center(
              child: ElevatedButton(
                onPressed: _navigateToEditPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF547EE8),
                  minimumSize: Size(358, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  '정보수정',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20), // 하단 여백 추가
          ],
        ),
      ),
    );
  }

  // 제목과 결과값을 한 번에 출력하는 위젯
  Widget _buildTitleWithValue(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Color(0xFFE3ECFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
