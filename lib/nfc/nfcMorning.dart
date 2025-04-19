
/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MedicineCheck(),
    );
  }
}

class MedicineCheck extends StatefulWidget {
  @override
  _MedicineCheckPageState createState() => _MedicineCheckPageState();
}

class _MedicineCheckPageState extends State<MedicineCheck> {
  bool isTaken = false;

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('MM/dd일 EEEE', 'ko_KR').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Container(
            color: Color(0xFF547EE8), //상단바 컬러
            padding: EdgeInsets.only(top: 37, bottom: 12), // 상단바 위쪽 높이 증가
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          todayDate,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.home, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '아침 약 입니다\n아침 약 드셨나요?',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isTaken = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTaken ? Color(0xFFA3BCF1) : Color(0xFF547EE8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(450, 200),
                    ),
                    child: Text(
                      isTaken ? '복용완료' : '네',
                      style: TextStyle(fontSize: 33, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 100),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF547EE8),
                      minimumSize: Size(358, 48), // 가로 358, 세로 48로 설정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      '복용 기록보기',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF547EE8),
                      minimumSize: Size(358, 48), // 가로 358, 세로 48로 설정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      '챗봇에게 질문하기',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


 */