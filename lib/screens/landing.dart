import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medife/providers/text_size_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medife/features/medication/MediMain/screen/medimain_screen.dart';
import 'package:medife/features/chatbot/screen/chatbot_screen.dart';
import 'package:medife/features/setting/setting.dart';
import 'package:medife/features/recording/recording.dart';
import 'package:medife/features/calendar/calendar.dart';
import 'package:medife/features/setting/mypage.dart';
import '../features/eatlist/component/eat-list.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String _nickname = '000';
  bool _taken = false;

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname') ?? '000';
    });
  }

  @override
  Widget build(BuildContext context) {
    final textSize = context.watch<TextSizeProvider>().textSize;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: const Color(0xFF547EE8),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: Text(
                            'MediTag',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: textSize * 1.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Semantics(
                            label: '환경설정',
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.settings, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SettingScreen()),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 120,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '안녕하세요, $_nickname님',
                                style: TextStyle(
                                  fontSize: textSize * 1.4,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '00약 복용 하셨나요?',
                                style: TextStyle(
                                  fontSize: textSize,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _taken = !_taken;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              _taken ? const Color(0xFFFFA4A5) : const Color(0xFF547EE8),
                              fixedSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _taken ? '복용 완료!' : '00약',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: textSize * 0.85,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _menuCard(
                    '챗봇',
                    Icons.smart_toy,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatBotScreen()),
                      );
                    },
                    fullWidth: true,
                    height: 100,
                    textSize: textSize,
                  ),
                  const SizedBox(height: 13),
                  Flexible(
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _menuCard('주의사항 녹음', Icons.mic, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RecordingScreen()),
                          );
                        }, textSize: textSize),
                        _menuCard('복약 알림 등록', Icons.notifications_active, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MediMainScreen()),
                          );
                        }, textSize: textSize),
                        _menuCard('복용 기록', Icons.edit_note, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EatList()),
                          );
                        }, textSize: textSize),
                        _menuCard('복약 달력', Icons.calendar_today, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Calendar()),
                          );
                        }, textSize: textSize),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF547EE8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyPage()),
            ).then((_) => _loadNickname());
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        items: [
          BottomNavigationBarItem(
            icon: Center(
              child: Icon(Icons.credit_card, size: 30),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Center(
              child: Icon(Icons.camera_alt, size: 30),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Center(
              child: Icon(Icons.person, size: 30),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, VoidCallback onTap,
      {bool fullWidth = false, double height = 80, required double textSize}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: textSize * 1.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                icon,
                color: const Color(0xFF547EE8),
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
