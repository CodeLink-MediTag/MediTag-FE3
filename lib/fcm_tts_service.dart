// lib/fcm_tts_service.dart
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 백그라운드 메시지 핸들러 (top-level)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 필요한 경우 Firebase 초기화 (background isolate)
  await Firebase.initializeApp();
  // 백그라운드에서는 TTS 실행하지 않음 (플러그인 문제). 알림을 띄우거나 로그만 남김.
  print('🌙 백그라운드 메시지 도착: ${message.messageId}, data=${message.data}, notification=${message.notification}');
}
// lib/fcm_tts_service.dart (계속)
class FcmTtsService {
  static final FcmTtsService _instance = FcmTtsService._internal();
  factory FcmTtsService() => _instance;
  FcmTtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final FlutterLocalNotificationsPlugin _localNoti = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification channel (Android)
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    // 1) flutter_local_notifications 초기화
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await _localNoti.initialize(initSettings, onDidReceiveNotificationResponse: (payload) {
      // 사용자가 알림을 탭했을 때: payload에 담긴 텍스트를 읽기
      final String? body = payload.payload;
      if (body != null && body.isNotEmpty) {
        _speak(body);
      }
    });

    // 채널 등록 (Android)
    await _localNoti.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 2) FCM 백그라운드 핸들러 등록 (앱 시작 시 한 번)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 3) 권한 요청 (iOS/Android 13)
    final messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔔 Notification permission: ${settings.authorizationStatus}');

    // 4) onMessage (포그라운드) 처리: 알림 띄우고 TTS 실행
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('📩 onMessage: ${message.notification?.title} / ${message.notification?.body}, data=${message.data}');
      final body = message.notification?.body ?? message.data['body'] ?? '';
      if (body.isNotEmpty) {
        // 로컬 알림도 띄움
        await _localNoti.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          message.notification?.title ?? '알림',
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: body,
        );

        // 포그라운드에서는 바로 TTS로 읽기
        await _speak(body);
      }
    });

    // 5) 앱이 알림에서 열렸을 때 (foreground / background -> 앱 열림)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔁 onMessageOpenedApp: ${message.data}');
      final body = message.notification?.body ?? message.data['body'] ?? '';
      if (body.isNotEmpty) {
        _speak(body);
      }
    });

    _initialized = true;
  }

  Future<void> _speak(String text) async {
    try {
      // 옵션 조정 (언어, 속도 등)
      await _flutterTts.setLanguage('ko-KR');
      await _flutterTts.setSpeechRate(0.45); // 0.3 ~ 0.6 등으로 조정
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS error: $e');
    }
  }

  // 토큰 얻기 등 유틸
  Future<String?> getFcmToken() async {
    return FirebaseMessaging.instance.getToken();
  }
}
