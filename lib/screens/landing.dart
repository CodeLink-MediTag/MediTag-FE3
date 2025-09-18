import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medife/providers/text_size_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:medife/features/medication/MediMain/screen/medimain_screen.dart';
import 'package:medife/features/chatbot/screen/chatbot_screen.dart';
import 'package:medife/features/setting/setting.dart';
import 'package:medife/features/recording/screen/recording_home_screen.dart';
import 'package:medife/features/calendar/screen/calendar_screen.dart';
import 'package:medife/features/mypage/mypage.dart';
import '../features/eatlist/component/eat-list.dart';
import 'package:medife/features/medication/MediMain/repository/medimain_medicine_repository.dart';
import '../nfc/nfcAdd.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String _nickname = '000';
  bool _taken = false;
  String? _favoriteMedName;
  String? _favoriteAlarmIso;
  int? _favoriteMedId;
  final MedicineRepository _repo = MedicineRepository();

  @override
  void initState() {
    super.initState();
    _loadNickname();
    _loadFavoriteData();
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    final storedNick = prefs.getString('nickname');
    final rawUser = prefs.getString('username') ?? '사용자';
    final displayUser = rawUser.contains('@') ? rawUser.split('@')[0] : rawUser;

    setState(() {
      _nickname = (storedNick != null && storedNick.isNotEmpty)
          ? storedNick
          : displayUser;
    });
  }

  Future<void> _loadFavoriteData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteMedName = prefs.getString('favoriteMedicine');
      _favoriteAlarmIso = prefs.getString('favoriteAlarmIso');
      _favoriteMedId = prefs.getInt('favoriteMedicineId');
      if (_favoriteAlarmIso != null) {
        final takenKey = 'taken_${_favoriteAlarmIso!}';
        _taken = prefs.getBool(takenKey) ?? false;
      } else {
        _taken = false;
      }
    });
  }

  Future<void> _onFavoriteButtonPressed() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (_favoriteAlarmIso == null || _favoriteMedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('즐겨찾기 약이 없습니다')));
      return;
    }

    final alarmTime = DateTime.tryParse(_favoriteAlarmIso!);
    if (alarmTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알람 시간 정보가 잘못되었습니다')));
      return;
    }

    final now = DateTime.now();
    final start = alarmTime.subtract(const Duration(hours: 1));
    final end = alarmTime.add(const Duration(hours: 1));

    if (!(now.isAfter(start) && now.isBefore(end))) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('복용 시간이 아닙니다')));
      setState(() {
        _taken = false;
      });
      return;
    }

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    final date = DateFormat('yyyy-MM-dd').format(alarmTime);
    try {
      await _repo.patchTaking(
        token: token,
        medicineId: _favoriteMedId!,
        alarmIso: _favoriteAlarmIso!,
        date: date,
        taking: true,
      );

      final takenKey = 'taken_${_favoriteAlarmIso!}';
      await prefs.setBool(takenKey, true);

      setState(() {
        _taken = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('복용 완료로 저장되었습니다')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 저장 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textSize = context
        .watch<TextSizeProvider>()
        .textSize;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final greetingText = _favoriteMedName != null
        ? '${_favoriteMedName!}약 복용 하셨나요?'
        : '좋은 하루 보내세요';

    final buttonLabel = _favoriteAlarmIso != null
        ? '${DateFormat('hh:mm a', 'ko_KR').format(
        DateTime.parse(_favoriteAlarmIso!))} ${_taken ? '복용 완료!' : '미복용'}'
        : (_favoriteMedName ?? '00약');

    double cardHeight = (textSize >= 18) ? 100 : 70;
    double chatbotCardHeight = (textSize >= 18) ? 120 : 90;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Stack(
            children: [
              Container(height: 200, width: double.infinity, color: cs.primary),
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
                              fontSize: textSize * 1.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.settings, color: cs.onPrimary),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => SettingScreen()));
                            },
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
                          BoxShadow(color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: (textSize >= 15)
                          ? Column( // 큰 글씨 버전 UI
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greetingText, style: TextStyle(
                              fontSize: textSize)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _taken ? null : _onFavoriteButtonPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _taken
                                  ? const Color(0xFFF4B7E8)
                                  : cs.primary,
                              fixedSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              buttonLabel,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: textSize * 0.8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                          : Row( // 기본 버전 UI
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '안녕하세요, $_nickname님',
                                style: TextStyle(fontSize: textSize * 1.4,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(greetingText,
                                  style: TextStyle(fontSize: textSize)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _taken ? null : _onFavoriteButtonPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _taken
                                  ? const Color(0xFFF4B7E8)
                                  : cs.primary,
                              fixedSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              buttonLabel,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: textSize * 0.8,
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
                  _menuCard('챗봇', Icons.smart_toy, () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => ChatBotScreen()));
                  }, fullWidth: true,
                      height: chatbotCardHeight,
                      textSize: textSize),
                  const SizedBox(height: 13),
                  Expanded(
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _menuCard('주의사항 녹음', Icons.mic, () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => RecordingHomeScreen()));
                        }, height: cardHeight, textSize: textSize),
                        _menuCard('복약 알림 등록', Icons.notifications_active, () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => MediMainScreen())).then((_) {
                            _loadFavoriteData();
                          });
                        }, height: cardHeight, textSize: textSize),
                        _menuCard('복용 기록', Icons.edit_note, () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => EatList()));
                        }, height: cardHeight, textSize: textSize),
                        _menuCard('복약 달력', Icons.calendar_today, () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => CalendarScreen()));
                        }, height: cardHeight, textSize: textSize),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        child: BottomNavigationBar(
          backgroundColor: cs.primary,
          selectedItemColor: cs.onPrimary,
          unselectedItemColor: cs.onPrimary.withOpacity(0.75),
          currentIndex: 0,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const CardRegistration()));
            }
            if (index == 1) {
              Navigator.pushNamed(context, '/ocr');
            }
            if (index == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyPage())).then((
                  _) {
                _loadNickname();
                _loadFavoriteData();
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Center(child: Icon(Icons.credit_card, size: 30)),
                label: ''),
            BottomNavigationBarItem(
                icon: Center(child: Icon(Icons.camera_alt, size: 30)), label: ''),
            BottomNavigationBarItem(
                icon: Center(child: Icon(Icons.person, size: 30)), label: ''),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, VoidCallback onTap,
      {bool fullWidth = false, double height = 80, required double textSize}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color cardColor = theme.cardColor;
    final Color iconColor = isDark ? cs.onSurface : cs.primary;
    final TextStyle titleStyle = (theme.textTheme.bodyLarge ??
        const TextStyle())
        .copyWith(fontSize: textSize * 1.4,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.bodyLarge?.color);

    final Color shadowColor = isDark ? Colors.black54 : Colors.black12;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardColor,
          boxShadow: [
            BoxShadow(
                color: shadowColor, blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: title.split(' ').map((word) => Text(
                  word,
                  style: titleStyle,
                )).toList(),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(icon, color: iconColor, size: 40),
            ),
          ],
        ),
      ),
    );
  }
}