// lib/screens/landing.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medife/providers/text_size_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medife/features/medication/MediMain/screen/medimain_screen.dart';
import 'package:medife/features/chatbot/screen/chatbot_screen.dart';
import 'package:medife/features/setting/setting.dart';
import 'package:medife/features/recording/screen/recording_home_screen.dart';
import 'package:medife/features/calendar/screen/calendar_screen.dart';
import 'package:medife/features/mypage/mypage.dart';
import '../features/eatlist/component/eat-list.dart';

import 'package:medife/features/medication/MediMain/repository/medimain_medicine_repository.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String _nickname = '000';
  bool _taken = false;
  String? _favoriteMedName;
  final MedicineRepository _repo = MedicineRepository();

  @override
  void initState() {
    super.initState();
    _loadNickname();
    _loadFavoriteMedicine();
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    final storedNick = prefs.getString('nickname');
    final rawUser = prefs.getString('username') ?? '사용자';
    final displayUser = rawUser.contains('@') ? rawUser.split('@')[0] : rawUser;

    setState(() {
      _nickname = (storedNick != null && storedNick.isNotEmpty) ? storedNick : displayUser;
    });
  }

  Future<void> _loadFavoriteMedicine() async {
    final prefs = await SharedPreferences.getInstance();
    final favName = prefs.getString('favoriteMedicine');
    setState(() {
      _favoriteMedName = favName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textSize = context.watch<TextSizeProvider>().textSize;
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    final greetingText = _favoriteMedName != null ? '${_favoriteMedName!}약 복용 하셨나요?' : '좋은 하루 보내세요';
    final buttonLabel = _favoriteMedName != null ? '${_favoriteMedName!} 약' : '00약';

    final Color buttonBg = _taken ? cs.secondary : cs.primary;
    final Color buttonFg = _taken ? cs.onSecondary : cs.onPrimary;

    final bottomBg = cs.primary;
    final bottomSelected = cs.onPrimary;
    final bottomUnselected = cs.onPrimary.withOpacity(0.75);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Stack(
            children: [
              // 상단 컬러 바 (테마 primary)
              Container(
                height: 200,
                width: double.infinity,
                color: cs.primary,
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
                              color: cs.onPrimary,
                              fontSize: (textSize ?? 14.0) * 1.8,
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
                              icon: Icon(Icons.settings, color: cs.onPrimary),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingScreen()));
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
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: (textSize >= 15)
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greetingText, style: TextStyle(fontSize: textSize)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _taken = !_taken;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _taken ? const Color(0xFFFFA4A5) : cs.primary,
                              fixedSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _taken ? '복용 완료!' : buttonLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: cs.onPrimary,
                                fontSize: textSize * 0.85,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                          : Row(
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
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                greetingText,
                                style: TextStyle(
                                  fontSize: textSize,
                                  color: theme.textTheme.bodyMedium?.color,
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
                              backgroundColor: buttonBg,
                              foregroundColor: buttonFg,
                              fixedSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _taken ? '복용 완료!' : buttonLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: buttonFg,
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotScreen()));
                    },
                    fullWidth: true,
                    height: 100,
                    textSize: textSize,
                    theme: theme,
                    cs: cs,
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
                        _menuCard(
                          '주의사항 녹음',
                          Icons.mic,
                              () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RecordingHomeScreen()));
                          },
                          textSize: textSize,
                          theme: theme,
                          cs: cs,
                        ),
                        _menuCard(
                          '복약 알림 등록',
                          Icons.notifications_active,
                              () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => MediMainScreen())).then((_) {
                              _loadFavoriteMedicine();
                            });
                          },
                          textSize: textSize,
                          theme: theme,
                          cs: cs,
                        ),
                        _menuCard(
                          '복용 기록',
                          Icons.edit_note,
                              () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EatList()));
                          },
                          textSize: textSize,
                          theme: theme,
                          cs: cs,
                        ),
                        _menuCard(
                          '복약 달력',
                          Icons.calendar_today,
                              () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarScreen()));
                          },
                          textSize: textSize,
                          theme: theme,
                          cs: cs,
                        ),
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
        backgroundColor: bottomBg,
        selectedItemColor: bottomSelected,
        unselectedItemColor: bottomUnselected,
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyPage()),
            ).then((_) {
              _loadNickname();
              _loadFavoriteMedicine();
            });
          }
          if (index == 1) {
            Navigator.pushNamed(context, '/ocr');
          }
          if (index == 0) {
            // 예시: 카드 등록 페이지로 이동하려면 해당 라우트로 이동
            // Navigator.push(context, MaterialPageRoute(builder: (context) => const CardRegistration()));
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        items: [
          BottomNavigationBarItem(
            icon: Center(
              child: Icon(Icons.credit_card, size: 30, color: cs.onPrimary),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Center(
              child: Icon(Icons.camera_alt, size: 30, color: cs.onPrimary),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Center(
              child: Icon(Icons.person, size: 30, color: cs.onPrimary),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, VoidCallback onTap,
      {bool fullWidth = false,
        double height = 80,
        required double textSize,
        required ThemeData theme,
        required ColorScheme cs}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                icon,
                color: cs.primary,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
