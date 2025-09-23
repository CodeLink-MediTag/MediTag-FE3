// lib/fcm_tts_service.dart
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ✅ 백그라운드 메시지 핸들러 (top-level)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // background isolate에서는 반드시 별도 초기화 필요
  try { await Firebase.initializeApp(); } catch (_) {}
  // ❌ 여기서는 TTS/위젯 접근 금지 (크래시 원인)
  // 필요 시 로컬 알림 '표시만' 하거나 로그만 찍기
  // (지금은 로그만)
  // ignore: avoid_print
  print('🌙 BG msg: ${message.messageId}, data=${message.data}, noti=${message.notification?.body}');
}

class FcmTtsService {
  static final FcmTtsService _instance = FcmTtsService._internal();
  factory FcmTtsService() => _instance;
  FcmTtsService._internal();

  final FlutterTts _tts = FlutterTts();
  final FlutterLocalNotificationsPlugin _localNoti = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  /// ✅ 앱이 포그라운드인지 체크해서 백그라운드 TTS 차단
  bool get _isForeground =>
      SchedulerBinding.instance.lifecycleState == AppLifecycleState.resumed;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1) 로컬 알림 초기화
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidInit);

    await _localNoti.initialize(
      initSettings,
      // 알림 탭하면 앱이 앞으로 온 뒤 콜백 진입 → 여기서만 TTS 허용
      onDidReceiveNotificationResponse: (NotificationResponse resp) async {
        final body = resp.payload;
        if (body != null && body.isNotEmpty) {
          await _speakSafely(body);
        }
      },
      // ❌ onDidReceiveBackgroundNotificationResponse에서는 TTS 금지
    );

    // 채널 등록 (Android)
    await _localNoti.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 2) FCM 권한 (Android 13+ / iOS)
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
    // ignore: avoid_print
    print('🔔 Notification permission: ${settings.authorizationStatus}');

    // 3) 포그라운드 수신: 로컬알림 표시 + 안전 TTS
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = message.notification?.title ?? '알림';
      final body = message.notification?.body ?? message.data['body'] ?? '';

      // 로컬 알림 표시 (포그라운드에서도 배지/히스토리용)
      if (body.isNotEmpty) {
        await _localNoti.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
            ),
          ),
          payload: body, // 탭 시 위 콜백으로 전달
        );

        // ✅ 포그라운드에서만 TTS
        await _speakSafely(body);
      }
    });

    // 4) 사용자가 알림 탭해서 앱을 연 경우 (백그라운드 → 포그라운드)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final body = message.notification?.body ?? message.data['body'] ?? '';
      if (body.isNotEmpty) {
        await _speakSafely(body);
      }
    });

    _initialized = true;
  }

  /// ✅ 항상 이걸로만 TTS 호출 (백그라운드/에러 가드)
  Future<void> _speakSafely(String text) async {
    if (text.isEmpty) return;
    if (!_isForeground) return; // 백그라운드에서는 말하지 않음

    try {
      // 초기 설정 (여기서 한 번 더 보장)
      await _tts.setLanguage('ko-KR');
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      try { await _tts.awaitSpeakCompletion(true); } catch (_) {}

      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      // ignore: avoid_print
      print('TTS error: $e');
    }
  }

  // 필요 시 외부에서 직접 호출
  Future<void> speak(String text) => _speakSafely(text);

  Future<String?> getFcmToken() => FirebaseMessaging.instance.getToken();
}
