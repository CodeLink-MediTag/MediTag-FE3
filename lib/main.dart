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
import 'features/nfc_tag/lunch_screen.dart';
import 'features/nfc_tag/nfc_app.dart';
import 'features/signup/screen/signup_screen.dart';
import 'screens/landing.dart';
import 'screens/guideline/guideline_screen.dart';
import 'firebase_options.dart';
import 'package:medife/features/mypage/mode/mode.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko_KR', null);
  // KakaoSdk는 앱 초기화 시 한 번만 호출하면 됩니다.
  KakaoSdk.init(nativeAppKey: 'YOUR_NATIVE_APP_KEY');

  runApp(const MyAppInitializer());
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

    // 기본값 안전하게 세팅
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
        ChangeNotifierProvider(create: (_) => NfcProvider()), // ✅ 추가
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


  @override
  void initState() {
    super.initState();
    _checkInitialNfcLaunch();
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
          context.read<NfcProvider>().setPendingRoute(route); // ✅ 저장만
          print("NFC값:$route");
        }
      }
    } catch (e) {
      debugPrint("초기 NFC 데이터 없음: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final nfcProvider = context.watch<NfcProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final textSizeProvider = context.watch<TextSizeProvider>();
    final double textSize = (textSizeProvider.textSize != null && textSizeProvider.textSize > 0)
        ? textSizeProvider.textSize
        : 14.0;
    final double textScaleFactor = textSize / 14.0;

    const Color brandColor = Color(0xFF547EE8);

    final ColorScheme baseLightScheme =
    ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.light);
    final ColorScheme baseDarkScheme =
    ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.dark);

    final ColorScheme lightScheme = baseLightScheme.copyWith(
      primary: brandColor,
      onPrimary: Colors.white,
      primaryContainer: brandColor,
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      fontFamily: 'SEBANG',
      brightness: Brightness.light,
      primaryColor: brandColor,
      appBarTheme: AppBarTheme(
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(brandColor),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ),
      scaffoldBackgroundColor: lightScheme.background,
      cardColor: lightScheme.surface,
      dividerColor: Colors.grey.shade300,
      listTileTheme: ListTileThemeData(
        textColor: lightScheme.onBackground,
        iconColor: lightScheme.onBackground.withOpacity(0.8),
        tileColor: lightScheme.surface,
      ),
      iconTheme: IconThemeData(color: lightScheme.onBackground.withOpacity(0.8)),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );

    final ColorScheme darkScheme = baseDarkScheme;

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      fontFamily: 'SEBANG',
      brightness: Brightness.dark,
      primaryColor: darkScheme.primary,
      scaffoldBackgroundColor: const Color(0xFF0F1115),
      appBarTheme: AppBarTheme(
        backgroundColor: darkScheme.surface,
        foregroundColor: darkScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(color: darkScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 20),
      ),
      cardColor: const Color(0xFF131417),
      dividerColor: Colors.grey.shade800,
      listTileTheme: ListTileThemeData(
        textColor: darkScheme.onBackground.withOpacity(0.95),
        iconColor: darkScheme.onBackground.withOpacity(0.85),
        tileColor: const Color(0xFF131417),
      ),
      iconTheme: IconThemeData(color: darkScheme.onBackground.withOpacity(0.85)),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );

    // 초기 라우트: 이미 로그인 되어 있으면 스플래시를 거쳐서 guideline/landing으로 보냄
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
        '/splash': (context) => SplashScreen(hasSeenGuideline: widget.hasSeenGuideline, firstLogin: widget.firstLogin),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/landing': (context) => const Landing(),
        '/ocr': (context) => OcrScreen(),
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

class SplashScreen extends StatefulWidget {
  final bool hasSeenGuideline;
  final bool firstLogin;
  const SplashScreen({super.key, required this.hasSeenGuideline, required this.firstLogin});

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

    // NFC 우선 처리
    if (nfcProvider.pendingRoute != null) {
      final pending = nfcProvider.pendingRoute!;
      nfcProvider.clearPendingRoute();

      // Navigator가 존재하는 context에서 안전하게 이동
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(pending, (route) => false);
      }
      return;
    }

    // NFC 없으면 기존 로직
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


