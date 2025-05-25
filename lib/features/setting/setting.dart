import 'package:flutter/material.dart';
import 'package:medife/features/setting/alertsound.dart';
import 'package:medife/nfc/nfcAdd.dart';
import '../../components/custom_app_bar.dart'; // CustomAppBar import 추가

class SettingScreen extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingScreen> {
  bool notifications = true;
  bool sound = true;
  bool vibration = true;
  bool showNotifications = false;
  double textSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: Column(
        children: [
          // CustomAppBar 적용
          const CustomAppBar(title: '환경설정'),

          Expanded(
            child: Container(
              color: Color(0xFFF6F6F6),
              child: Column(
                children: [
                  _buildSettingTile('알림', Switch(
                    value: notifications,
                    onChanged: (value) {
                      setState(() => notifications = value);
                    },
                    activeColor: Colors.blue,
                  )),
                  _buildDivider(),
                  _buildSettingTile('소리', Switch(
                    value: sound,
                    onChanged: (value) {
                      setState(() => sound = value);
                    },
                    activeColor: Colors.blue,
                  )),
                  _buildDivider(),
                  _buildNavigationButton('알림음', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AlertSound()),
                    );
                  }),
                  _buildDivider(),
                  _buildSettingTile('진동', Switch(
                    value: vibration,
                    onChanged: (value) {
                      setState(() => vibration = value);
                    },
                    activeColor: Colors.blue,
                  )),
                  _buildDivider(),
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Color(0xFFFDFDFD),
                    child: Column(
                      children: [
                        Text(
                          '글자 크기',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                        Slider(
                          value: textSize,
                          min: 10,
                          max: 24,
                          divisions: 7,
                          label: textSize.toString(),
                          onChanged: (value) {
                            setState(() => textSize = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingTile('알림 표시', Switch(
                    value: showNotifications,
                    onChanged: (value) {
                      setState(() => showNotifications = value);
                    },
                    activeColor: Colors.blue,
                  )),
                  _buildDivider(),
                  _buildNavigationButton('NFC 등록', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CardRegistration()),
                    );
                  }),
                  _buildDivider(),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF547EE8),
                        minimumSize: Size(358, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        '로그아웃',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
                      ),
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

  Widget _buildSettingTile(String title, Widget trailing) {
    return Container(
      color: Color(0xFFFDFDFD),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildNavigationButton(String title, VoidCallback onPressed) {
    return Container(
      color: Color(0xFFFDFDFD),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      color: Color(0xFFDADADA),
    );
  }
}
