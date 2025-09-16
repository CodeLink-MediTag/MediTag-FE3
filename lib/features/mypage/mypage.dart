// lib/features/mypage/mypage.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/features/mypage/nickname.dart';
import 'package:medife/features/mypage/guardian/GuardianAlert/guardian_alert_container.dart';
import 'package:medife/features/mypage/guardian/GuardianEdit/guardian_edit_container.dart';
import 'package:medife/features/mypage/unregister/unregister_screen.dart';
import 'package:medife/features/mypage/mode/mode.dart';
import 'package:provider/provider.dart';
import 'package:medife/features/mypage/mode/fancy_toggle_switch.dart';


class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String _nickname = '000';
  Uint8List? _profileBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final storedNick = prefs.getString('nickname');
    final rawUser = prefs.getString('username') ?? '';
    final user = rawUser.contains('@') ? rawUser.split('@')[0] : (rawUser.isNotEmpty ? rawUser : '사용자');
    final displayNick = (storedNick != null && storedNick.isNotEmpty) ? storedNick : user;

    final base64Image = prefs.getString('profileImageBase64');
    Uint8List? imageBytes;
    if (base64Image != null) {
      imageBytes = base64Decode(base64Image);
    }

    setState(() {
      _nickname = displayNick;
      _profileBytes = imageBytes;
    });
  }

  Future<void> _navigateToEditNickname() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Nickname(currentNickname: _nickname)),
    );
    if (result != null && result is String) {
      setState(() {
        _nickname = result;
      });
      await _loadUserData();
    }
  }

  Future<void> _navigateToGuardianPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GuardianAlert()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // header (테마 사용)
          Container(
            color: cs.primary,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: cs.onPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '마이페이지',
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.cardColor,
                  backgroundImage: _profileBytes != null ? MemoryImage(_profileBytes!) : null,
                  child: _profileBytes == null
                      ? Icon(Icons.account_circle, size: 60, color: cs.onPrimary)
                      : null,
                ),
                const SizedBox(height: 10),
                Text('안녕하세요', style: TextStyle(color: cs.onPrimary)),
                const SizedBox(height: 4),
                Text(
                  '$_nickname님,\n안온한 하루 되세요.',
                  style: TextStyle(color: cs.onPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // menu list
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(context, "내 정보 수정", () => _navigateToEditNickname()),
                _buildMenuItem(context, "보호자 알림", () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GuardianAlert()));
                  setState(() {});
                }),

                _buildMenuItem(context, "보기 방식 변경", () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      final themeProv = ctx.read<ThemeProvider>();

                      // 현재 라이트인지 여부를 bool로 계산 (system이면 플랫폼 밝기 기준)
                      bool currentIsLight;
                      if (themeProv.mode == AppThemeMode.system) {
                        currentIsLight = MediaQuery.of(ctx).platformBrightness == Brightness.light;
                      } else {
                        currentIsLight = themeProv.mode == AppThemeMode.light;
                      }

                      return StatefulBuilder(builder: (c, localSetState) {
                        return AlertDialog(
                          title: const Text('보기 방식 변경'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 6),
                              Center(
                                child: FancyToggleSwitch(
                                  value: currentIsLight, // true = 라이트, false = 다크
                                  width: 160,
                                  height: 46,
                                  onLabel: '라이트',
                                  offLabel: '다크',
                                  onChanged: (val) async {
                                    // UI 즉시 반영
                                    localSetState(() => currentIsLight = val);
                                    // Provider에 저장 (persist)
                                    final newMode = val ? AppThemeMode.light : AppThemeMode.dark;
                                    await themeProv.setMode(newMode);
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '시스템 설정과 동기화하려면 앱 설정에서 시스템 모드를 선택하세요.',
                                style: Theme.of(ctx).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              // 시스템 모드로 되돌리는 버튼 (선택 기능)
                              TextButton(
                                onPressed: () async {
                                  await themeProv.setMode(AppThemeMode.system);
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('시스템 모드로 변경'),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('닫기')),
                          ],
                        );
                      });
                    },
                  );
                }),
                _buildMenuItem(context, "회원탈퇴", () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UnregisterScreen()));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: ListTile(
        title: Text(title, style: theme.textTheme.bodyLarge),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: Border(bottom: BorderSide(color: theme.dividerColor)),
        tileColor: theme.cardColor,
      ),
    );
  }
}
