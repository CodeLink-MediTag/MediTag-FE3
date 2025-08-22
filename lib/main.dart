import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medife/features/ocr/ocr.dart';
import 'package:medife/providers/text_size_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'features/login/screen/login_screen.dart';
import 'features/nfc_tag/nfc_app.dart';
import 'features/signup/screen/signup_screen.dart';
import 'screens/landing.dart';
import 'screens/guideline/guideline_screen.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko_KR', null);
  KakaoSdk.init(nativeAppKey: 'YOUR_NATIVE_APP_KEY');

  runApp(
    const MyAppInitializer(),
  );
}

class MyAppInitializer extends StatefulWidget {
  const MyAppInitializer({super.key});

  @override
  State<MyAppInitializer> createState() => _MyAppInitializerState();
}

class _MyAppInitializerState extends State<MyAppInitializer> {
  bool? hasSeenGuideline;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _checkInitialNfcLaunch(); // 🔥 추가

  }

  Future<void> _initializeApp() async {
    prefs = await SharedPreferences.getInstance();

    // 🔥 'hasSeenGuideline'이 null인 경우 기본값을 false로 설정
    final seenGuideline = prefs.getBool('hasSeenGuideline') ?? false;

    setState(() {
      hasSeenGuideline = seenGuideline;
    });
  }

  // NFC 앱 실행 시 데이터 확인
  Future<void> _checkInitialNfcLaunch() async {
    const platform = MethodChannel('nfc_channel');
    try {
      final String? cardInfo = await platform.invokeMethod('getInitialNfcData');
      if (cardInfo != null && cardInfo.isNotEmpty) {
        _navigateToTimeScreen(cardInfo);
      }
    } catch (e) {
      debugPrint("초기 NFC 데이터 없음: $e");
    }
  }
  void _navigateToTimeScreen(String cardInfo) {
    String route = '';
    if (cardInfo == "morning_card") route = '/morning';
    else if (cardInfo == "lunch_card") route = '/lunch';
    else if (cardInfo == "dinner_card") route = '/dinner';

    if (route.isNotEmpty) {
      // 로그인 화면 이후 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(context, route);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (hasSeenGuideline == null) {
      // 아직 초기화 중이면 로딩 화면
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => TextSizeProvider(),
      child: MyApp(hasSeenGuideline: hasSeenGuideline!),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool hasSeenGuideline;
  const MyApp({super.key, required this.hasSeenGuideline});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediTag',
      theme: ThemeData(
        fontFamily: 'SEBANG',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      builder: (context, child) {
        final textSizeProvider = context.watch<TextSizeProvider>();
        final double textSize = (textSizeProvider.textSize != null && textSizeProvider.textSize > 0)
            ? textSizeProvider.textSize
            : 14.0;
        final double textScaleFactor = textSize / 14.0;

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: textScaleFactor,
          ),
          child: child!,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/landing': (context) => Landing(),
        '/ocr' : (context) => OcrScreen(),
        '/guideline': (context) => const GuidelineScreen(),
        // 카드별로 화면 이동
        '/morning': (context) => MorningScreen(),
        '/lunch': (context) => LunchScreen(),
        '/dinner': (context) => DinnerScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
