import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // flutterfire configure 로 생성된 파일

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(home: Scaffold(body: MyApp())));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _fcmToken;

  Future<void> getFCMToken() async {
    try {
      // 권한 요청 (Android 13 이상 또는 iOS 필요)
      await FirebaseMessaging.instance.requestPermission();

      // 토큰 가져오기
      String? token = await FirebaseMessaging.instance.getToken();
      setState(() {
        _fcmToken = token;
      });

      print('📌 FCM Token: $token'); // 콘솔 출력
    } catch (e) {
      print('❌ FCM 토큰 가져오기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: getFCMToken,
            child: const Text('FCM 토큰 가져오기'),
          ),
          const SizedBox(height: 20),
          Text(_fcmToken ?? '토큰 없음'),
        ],
      ),
    );
  }
}
