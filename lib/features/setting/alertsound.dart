
import 'package:flutter/material.dart';



class AlertSound extends StatefulWidget {
  @override
  _AlertSoundPageState createState() => _AlertSoundPageState();
}

class _AlertSoundPageState extends State<AlertSound> {
  String selectedSound = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6), // 연한 회색 배경
      body: Column(
        children: [
          Container(
            color: Color(0xFF547EE8),
            padding: EdgeInsets.only(top: 37, bottom: 12), // 상단바 위쪽 높이 증가
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
                    '알림음',
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
          _buildSoundTile('알림음1'),
          _buildDivider(),
          _buildSoundTile('알림음2'),
          _buildDivider(),
          _buildSoundTile('알림음3'),
        ],
      ),
    );
  }

  Widget _buildSoundTile(String soundName) {
    return Container(
      color: Colors.white, // 알림음 칸만 흰색
      child: ListTile(
        title: Text(
          soundName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400), // 폰트 크기 20, Regular 적용
        ),
        trailing: Checkbox(
          value: selectedSound == soundName,
          onChanged: (value) {
            setState(() => selectedSound = value! ? soundName : "");
          },
          activeColor: Color(0xFF61B781), /// 체크박스 반응색
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      color: Color(0xFFDADADA),
      width: double.infinity, // 좌우 여백 없이 끝까지
    );
  }
}


