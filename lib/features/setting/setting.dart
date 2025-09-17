// lib/features/setting/setting.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:medife/nfc/nfcAdd.dart';
import '../../components/custom_app_bar.dart';
import 'package:medife/providers/text_size_provider.dart';
import '../../components/custom_primary_button.dart'; // 커스텀 버튼

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingScreen> {
  bool notifications = true;
  String notificationMode = '소리만';
  final List<String> notificationOptions = ['소리만', '진동', '소리 + 진동'];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSettings();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notifications = prefs.getBool('notifications') ?? true;
      notificationMode = prefs.getString('notification_mode') ?? '소리만';
    });
  }

  Future<void> _saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
  }

  Future<void> _saveNotificationMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_mode', mode);
  }

  void _updateNotificationSettings(String mode) async {
    const AndroidNotificationDetails androidDetailsSound = AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: '알림 채널',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: false,
    );

    const AndroidNotificationDetails androidDetailsVibration = AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: '알림 채널',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      enableVibration: true,
    );

    const AndroidNotificationDetails androidDetailsSoundVibration = AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: '알림 채널',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    AndroidNotificationDetails androidDetails;

    switch (mode) {
      case '소리만':
        androidDetails = androidDetailsSound;
        break;
      case '진동':
        androidDetails = androidDetailsVibration;
        break;
      case '소리 + 진동':
        androidDetails = androidDetailsSoundVibration;
        break;
      default:
        androidDetails = androidDetailsSound;
    }

    final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      '알림 테스트',
      '현재 설정: $mode',
      notificationDetails,
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final textSizeProvider = Provider.of<TextSizeProvider>(context);
    final double textSize = textSizeProvider.textSize;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // 상단 커스텀 앱바 (기존 코드 유지)
          const CustomAppBar(title: '환경설정'),

          // 컨텐츠 영역 (스크롤 가능)
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                padding: EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 0,
                  // 키보드가 올라오면 viewInsets.bottom 만큼 추가 여백을 줘서
                  // 리스트 내용이 키보드에 가려지지 않도록 함
                  bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom + 24,
                ),
                children: [
                  // (예시) 알림 토글 행
                  Container(
                    color: theme.cardColor,
                    child: Column(
                      children: [
                        _buildSettingTile('알림', Switch(
                          value: notifications,
                          onChanged: (value) {
                            setState(() {
                              notifications = value;
                              _saveNotifications(notifications);
                              if (!notifications) {
                                flutterLocalNotificationsPlugin.cancelAll();
                              }
                            });
                          },
                          activeColor: cs.primary,
                        ), textSize),
                        _buildDivider(),
                        if (notifications)
                          Container(
                            color: theme.cardColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListTile(
                              title: Text(
                                '알림 설정',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: textSize),
                              ),
                              trailing: DropdownButton<String>(
                                value: notificationMode,
                                items: notificationOptions.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(fontSize: textSize)),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    notificationMode = newValue!;
                                    _saveNotificationMode(notificationMode);
                                    _updateNotificationSettings(
                                        notificationMode);
                                  });
                                },
                              ),
                            ),
                          ),
                        if (notifications) _buildDivider(),
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: theme.cardColor,
                          child: Column(
                            children: [
                              Text('글자 크기',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: textSize)),
                              Slider(
                                value: textSize,
                                min: 14,
                                max: 18,
                                divisions: 7,
                                label: textSize.toStringAsFixed(1),
                                activeColor: cs.primary,
                                onChanged: (value) {
                                  textSizeProvider.setTextSize(value);
                                },
                              ),
                            ],
                          ),
                        ),
                        _buildDivider(),
                        _buildNavigationButton('NFC 등록', () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => CardRegistration()));
                        }, textSize),
                        _buildDivider(),
                        const SizedBox(height: 8),
                        // 필요하면 여기에 추가 설정 항목들...
                      ],
                    ),
                  ),
                  const SizedBox(height: 90), // 리스트 끝에서 버튼이 가리는 걸 방지하기 위한 여유
                ],
              ),
            ),
          ),
        ],
      ),

      // <- 핵심: 버튼을 bottomNavigationBar로 넣어서 항상 화면 하단에 고정
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: CustomPrimaryButton(
            label: '로그아웃', // 혹시 '로그인' 버튼을 원하면 라벨/콜백만 바꿔
            onPressed: () async {
              await _logout(context);
            },
            margin: EdgeInsets.zero,
            height: 52,
          ),
        ),
      ),
    );
  }

// helper 함수들 (기존 것을 context 참조형으로 바꿔 사용)
  Widget _buildSettingTile(String title, Widget trailing, double fontSize) {
    return Container(
      color: Theme
          .of(context)
          .cardColor,
      child: ListTile(
        title: Text(
          title,
          style: Theme
              .of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontSize: fontSize),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildNavigationButton(String title, VoidCallback onPressed,
      double fontSize) {
    return Container(
      color: Theme
          .of(context)
          .cardColor,
      child: ListTile(
        title: Text(title, style: Theme
            .of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontSize: fontSize)),
        trailing: Icon(Icons.arrow_forward_ios, color: Theme
            .of(context)
            .iconTheme
            .color, size: 20),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 2, color: Theme
        .of(context)
        .dividerColor);
  }
}