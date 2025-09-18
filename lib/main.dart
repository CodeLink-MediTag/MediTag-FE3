// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medife/features/ocr/ocr.dart';
import 'package:medife/providers/nfc_provider.dart';
import 'package:medife/providers/text_size_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'features/login/screen/login_screen.dart';
import 'features/nfc_tag/medicine_intake_screen.dart';
import 'features/signup/screen/signup_screen.dart';
import 'screens/landing.dart';
import 'screens/guideline/guideline_screen.dart';
import 'firebase_options.dart';
import 'package:medife/features/mypage/mode/mode.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'fcm_tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('ko_KR', null);
  // ❗️ 실제 카카오 네이티브 앱 키로 변경해야 합니다.
  KakaoSdk.init(nativeAppKey: 'YOUR_NATIVE_APP_KEY');

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyAppInitializer());

  await FcmTtsService().initialize();
}

class MyAppInitializer extends StatefulWidget {
  const MyAppInitializer({super.key});

  @override
  State<MyAppInitializer> createState() => _MyAppInitializerState();
}

class _MyAppInitializerState extends State<MyAppInitializer> {
  bool? hasSeenGuideline;
  bool? isLoggedIn;
  bool? firstLogin;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    prefs = await SharedPreferences.getInstance();

    // ✅ 수정된 부분: isLoggedIn 키가 없을 경우 false로 초기화합니다.
    if (!prefs.containsKey('isLoggedIn')) {
      await prefs.setBool('isLoggedIn', false);
    }
    if (!prefs.containsKey('firstLogin')) {
      await prefs.setBool('firstLogin', true);
    }
    if (!prefs.containsKey('hasSeenGuideline')) {
      await prefs.setBool('hasSeenGuideline', false);
    }

    final seenGuideline = prefs.getBool('hasSeenGuideline') ?? false;
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    final firstLoginVal = prefs.getBool('firstLogin') ?? true;

    setState(() {
      hasSeenGuideline = seenGuideline;
      isLoggedIn = loggedIn;
      firstLogin = firstLoginVal;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasSeenGuideline == null || isLoggedIn == null || firstLogin == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TextSizeProvider()),
        ChangeNotifierProvider(create: (_) => NfcProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(
        hasSeenGuideline: hasSeenGuideline!,
        isLoggedIn: isLoggedIn!,
        firstLogin: firstLogin!,
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final bool hasSeenGuideline;
  final bool isLoggedIn;
  final bool firstLogin;

  const MyApp({
    super.key,
    required this.hasSeenGuideline,
    required this.isLoggedIn,
    required this.firstLogin,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _checkInitialNfcLaunch();
    _setupFcmAndTts();
  }

  Future<void> _setupFcmAndTts() async {
    try {
      final messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');

      final String? token = await messaging.getToken();
      debugPrint('🔥 FCM token: $token');

      try {
        await _flutterTts.setLanguage('ko-KR');
        await _flutterTts.setSpeechRate(0.45);
        await _flutterTts.setVolume(1.0);
      } catch (e) {
        debugPrint('TTS init warning: $e');
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final title = message.notification?.title ?? '';
        final body = message.notification?.body ?? message.data['body'] ?? '';
        final speakText =
        body.isNotEmpty ? body : (title.isNotEmpty ? title : '새 알림이 도착했습니다.');

        try {
          await _flutterTts.stop();
          await _flutterTts.speak(speakText);
        } catch (e) {
          debugPrint('TTS error: $e');
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📝 onMessageOpenedApp: data=${message.data}');
      });

      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('📝 getInitialMessage: data=${initialMessage.data}');
      }
    } catch (e) {
      debugPrint('FCM+TTS setup error: $e');
    }
  }

  Future<void> _checkInitialNfcLaunch() async {
    const platform = MethodChannel('nfc_channel');
    try {
      final String? cardInfo = await platform.invokeMethod('getInitialNfcData');
      if (cardInfo != null && cardInfo.isNotEmpty) {
        String? route;
        if (cardInfo == "morning_card") route = '/morning';
        else if (cardInfo == "lunch_card") route = '/lunch';
        else if (cardInfo == "dinner_card") route = '/dinner';

        if (route != null) {
          context.read<NfcProvider>().setPendingRoute(route);
          print("NFC값:$route");
        }
      }
    } catch (e) {
      debugPrint("초기 NFC 데이터 없음: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final textSizeProvider = context.watch<TextSizeProvider>();
    final double textSize =
    (textSizeProvider.textSize != null && textSizeProvider.textSize > 0)
        ? textSizeProvider.textSize
        : 14.0;
    final double textScaleFactor = textSize / 14.0;

    const Color brandColor = Color(0xFF547EE8); // 라이트 블루
    const Color darkPink = Color(0xFFFF98BE); // 다크모드용 톤다운 핑크

    final ColorScheme baseLightScheme =
    ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.light);
    final ColorScheme baseDarkScheme =
    ColorScheme.fromSeed(seedColor: darkPink, brightness: Brightness.dark);

    final ColorScheme lightScheme = baseLightScheme.copyWith(
      primary: brandColor,
      onPrimary: Colors.white,
      primaryContainer: brandColor,
    );

    final ColorScheme darkScheme = baseDarkScheme.copyWith(
      primary: darkPink,
      onPrimary: Colors.white,
    );

    // 라이트 테마
    final ThemeData lightTheme = ThemeData(
      colorScheme: lightScheme,
      brightness: Brightness.light,
      primaryColor: brandColor,
      useMaterial3: true,
      fontFamily: 'SEBANG',
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: lightScheme.onBackground,
        displayColor: lightScheme.onBackground,
        fontFamily: 'SEBANG',
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightScheme.primary,
        foregroundColor: lightScheme.onPrimary,
        elevation: 2,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: lightScheme.onPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          fontFamily: 'SEBANG',
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: lightScheme.primary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightScheme.primary,
        foregroundColor: lightScheme.onPrimary,
      ),
      scaffoldBackgroundColor: lightScheme.background,
      cardColor: lightScheme.surface,
      dividerColor: Colors.grey.shade300,
    );

    // 다크 테마
    final ThemeData darkTheme = ThemeData(
      colorScheme: darkScheme,
      brightness: Brightness.dark,
      primaryColor: darkPink,
      useMaterial3: true,
      fontFamily: 'SEBANG',
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: darkScheme.onBackground,
        displayColor: darkScheme.onBackground,
        fontFamily: 'SEBANG',
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkPink,
        foregroundColor: Colors.white, // 앱바 글씨 흰색
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          fontFamily: 'SEBANG',
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: darkPink),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPink,
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F1115),
      cardColor: const Color(0xFF131417),
      dividerColor: Colors.grey.shade800,
      iconTheme: IconThemeData(color: darkScheme.onBackground.withOpacity(0.95)),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkScheme.surface,
        selectedItemColor: darkPink,
        unselectedItemColor: darkScheme.onBackground.withOpacity(0.6),
      ),
    );

    // ✅ 로그인 상태 따라 initialRoute 분기
    final String initialRoute = widget.isLoggedIn ? '/splash' : '/login';

    return MaterialApp(
      title: 'MediTag',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: textScaleFactor),
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: initialRoute,
      routes: {
        '/': (context) => widget.isLoggedIn
            ? SplashScreen(
          hasSeenGuideline: widget.hasSeenGuideline,
          firstLogin: widget.firstLogin,
        )
            : LoginScreen(),
        '/splash': (context) => SplashScreen(
          hasSeenGuideline: widget.hasSeenGuideline,
          firstLogin: widget.firstLogin,
        ),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/landing': (context) => const Landing(),
        '/ocr': (context) => OcrScreen(),
        '/guideline': (context) => const GuidelineScreen(),
        '/morning': (context) => MedicineIntakeScreen(
          timeLabel: '아침',
          targetTime: '08:00:00',
        ),
        '/lunch': (context) => MedicineIntakeScreen(
          timeLabel: '점심',
          targetTime: '12:00:00',
        ),
        '/dinner': (context) => MedicineIntakeScreen(
          timeLabel: '저녁',
          targetTime: '18:00:00',
        ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  final bool hasSeenGuideline;
  final bool firstLogin;
  const SplashScreen(
      {super.key, required this.hasSeenGuideline, required this.firstLogin});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final nfcProvider = context.read<NfcProvider>();

    if (nfcProvider.pendingRoute != null) {
      final pending = nfcProvider.pendingRoute!;
      nfcProvider.clearPendingRoute();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(pending, (route) => false);
      }
      return;
    }

    // ✅ 첫 로그인 + 가이드라인 안봤으면 가이드라인으로
    if (widget.firstLogin && !widget.hasSeenGuideline) {
      if (mounted) Navigator.of(context).pushReplacementNamed('/guideline');
    } else {
      if (mounted) Navigator.of(context).pushReplacementNamed('/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}