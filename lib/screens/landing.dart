import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/features/chatbot/chatbot.dart';
import 'package:medife/features/setting/setting.dart';
import 'package:medife/features/recording/recording.dart';
import 'package:medife/features/medication/MediMain.dart';
import 'package:medife/features/calendar/calendar.dart';
import 'package:medife/features/eatlist/eatlist.dart';
import 'package:medife/features/setting/mypage.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String _nickname = '000';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: const Color(0xFF7D8FF7),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                child: Column(
                  children: [
                    // 탑바
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Center(
                            child: Text(
                              'MediTag',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 약복용 알림창
                    Container(
                      width: double.infinity,
                      height: 120,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
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
                              Text('안녕하세요, $_nickname님',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text('00약 복용 하셨나요?'),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7D8FF7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('00약'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(height: 20,),
          // 주요버튼 5개
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  _menuCard('챗봇', Icons.smart_toy, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ChatBot()));
                  }, fullWidth: true, height: 100),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _menuCard('주의사항 녹음', Icons.mic, () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => RecordingScreen()));
                      }),
                      _menuCard('복약 알림 등록', Icons.notifications_active, () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MediMain()));
                      }),
                      _menuCard('복용 기록', Icons.edit_note, () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => EatList()));
                      }),
                      _menuCard('복약 달력', Icons.calendar_today, () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Calendar()));
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF7D8FF7),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyPage()),
            ).then((_) => _loadNickname()); // ✅ 뒤에서 닉네임 변경 후 돌아올 때 다시 로딩
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, VoidCallback onTap,
      {bool fullWidth = false, double height = 80}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Icon(icon, color: const Color(0xFF7D8FF7), size: 28),
          ],
        ),
      ),
    );
  }
}
