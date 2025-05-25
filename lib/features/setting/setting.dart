import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medife/features/setting/alertsound.dart';
import 'package:medife/nfc/nfcAdd.dart';
import 'package:medife/providers/text_size_provider.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingScreen> {
  bool notifications = true;
  bool isDarkMode = false;  // 다크모드 토글 상태 변수

  @override
  Widget build(BuildContext context) {
    final textSizeProvider = context.watch<TextSizeProvider>();

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: Column(
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Center(
                  child: Text(
                    '환경설정',
                    style: TextStyle(
                      fontSize: textSizeProvider.textSize + 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xFFF6F6F6),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSettingTile(
                    '알림',
                    Switch(
                      value: notifications,
                      onChanged: (value) {
                        setState(() {
                          notifications = value;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                    textSizeProvider.textSize,
                  ),
                  _buildDivider(),

                  // 다크모드 토글 UI 추가
                  _buildSettingTile(
                    '다크모드',
                    Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isDarkMode = value;
                        });
                        // 기능 구현은 나중에
                      },
                      activeColor: Colors.blue,
                    ),
                    textSizeProvider.textSize,
                  ),
                  _buildDivider(),

                  Container(
                    padding: EdgeInsets.all(16),
                    color: Color(0xFFFDFDFD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '글자 크기',
                          style: TextStyle(
                            fontSize: textSizeProvider.textSize,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Slider(
                          value: textSizeProvider.textSize,
                          min: 10,
                          max: 24,
                          divisions: 7,
                          label: textSizeProvider.textSize.toStringAsFixed(1),
                          onChanged: (value) {
                            textSizeProvider.setTextSize(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildDivider(),
                  _buildNavigationButton(
                    '알림음',
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AlertSound()),
                      );
                    },
                    textSizeProvider.textSize,
                  ),
                  _buildDivider(),
                  _buildNavigationButton(
                    'NFC 등록',
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CardRegistration()),
                      );
                    },
                    textSizeProvider.textSize,
                  ),
                  _buildDivider(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF547EE8),
            minimumSize: Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            '로그아웃',
            style: TextStyle(
              fontSize: textSizeProvider.textSize,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, Widget trailing, double fontSize) {
    return Container(
      color: Color(0xFFFDFDFD),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w400),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildNavigationButton(String title, VoidCallback onPressed, double fontSize) {
    return Container(
      color: Color(0xFFFDFDFD),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w400),
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
