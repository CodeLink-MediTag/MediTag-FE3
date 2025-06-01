import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:medife/features/setting/alertsound.dart';
import 'package:medife/nfc/nfcAdd.dart';
import '../../components/custom_app_bar.dart';
import 'package:medife/providers/text_size_provider.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingScreen> {
  bool notifications = true;
  String notificationMode = '소리만';
  List<String> notificationOptions = ['소리만', '진동', '소리 + 진동'];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSettings();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notifications = prefs.getBool('notifications') ?? true;
      notificationMode = prefs.getString('notification_mode') ?? '소리만';
    });

    // 텍스트 크기는 Provider에서 불러오므로 여기선 따로 불러올 필요 없음
  }

  Future<void> _saveNotifications(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
  }

  Future<void> _saveNotificationMode(String mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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

    final NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      '알림 테스트',
      '현재 설정: $mode',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textSizeProvider = Provider.of<TextSizeProvider>(context);
    final double textSize = textSizeProvider.textSize;

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: Column(
        children: [
          // CustomAppBar에 textSize 전달 (원한다면)
          CustomAppBar(
            title: '환경설정',
            // 만약 CustomAppBar가 fontSize 지원한다면 여기에 전달
            // fontSize: textSize,
          ),
          Expanded(
            child: Container(
              color: Color(0xFFF6F6F6),
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
                    activeColor: Colors.blue,
                  ), textSize),
                  _buildDivider(),
                  if (notifications)
                    Container(
                      color: Color(0xFFFDFDFD),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ListTile(
                        title: Text(
                          '알림 설정',
                          style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w400),
                        ),
                        trailing: DropdownButton<String>(
                          value: notificationMode,
                          items: notificationOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option, style: TextStyle(fontSize: textSize)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              notificationMode = newValue!;
                              _saveNotificationMode(notificationMode);
                              _updateNotificationSettings(notificationMode);
                            });
                          },
                        ),
                      ),
                    ),
                  if (notifications) _buildDivider(),
                  if (notifications)
                    _buildNavigationButton('알림음', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AlertSound()),
                      );
                    }, textSize),
                  if (notifications) _buildDivider(),
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Color(0xFFFDFDFD),
                    child: Column(
                      children: [
                        Text('글자 크기', style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w400)),
                        Slider(
                          value: textSize,
                          min: 10,
                          max: 24,
                          divisions: 7,
                          label: textSize.toStringAsFixed(1),
                          onChanged: (value) {
                            textSizeProvider.setTextSize(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildDivider(),
                  _buildNavigationButton('NFC 등록', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CardRegistration()),
                    );
                  }, textSize),
                  _buildDivider(),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        // 로그아웃 로직 추가 가능
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF547EE8),
                        minimumSize: Size(358, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        '로그아웃',
                        style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w400, color: Colors.white),
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
