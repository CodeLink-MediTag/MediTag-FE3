// main.dart
import 'package:flutter/material.dart';
import 'package:medife/features/ocr/ocr.dart';
import 'package:medife/providers/text_size_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'features/login/screen/login_screen.dart';
import 'features/signup/screen/signup_screen.dart';
import 'screens/landing.dart';
import 'screens/guideline/guideline_screen.dart';
import 'providers/text_size_provider.dart';
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

    // 기본값 명시적 설정 (앱 최초 실행 시 대비)
    if (!prefs.containsKey('firstLogin')) {
      await prefs.setBool('firstLogin', true);
    }
    if (!prefs.containsKey('hasSeenGuideline')) {
      await prefs.setBool('hasSeenGuideline', false);
    }

    final seenGuideline = prefs.getBool('hasSeenGuideline') ?? false;
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    final firstLoginVal = prefs.getBool('firstLogin') ?? true;
    print('App init: hasSeenGuideline=$seenGuideline, firstLogin=$firstLogin');

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

    return ChangeNotifierProvider(
      create: (_) => TextSizeProvider(),
      child: MyApp(
        hasSeenGuideline: hasSeenGuideline!,
        isLoggedIn: isLoggedIn!,
        firstLogin: firstLogin!,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
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
      initialRoute: isLoggedIn ? '/splash' : '/login',
      onGenerateRoute: (settings) {
        if (settings.name == '/splash') {
          return MaterialPageRoute(builder: (context) => SplashScreen(
            hasSeenGuideline: hasSeenGuideline,
            firstLogin: firstLogin,
          ));
        }
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => SignupScreen());
          case '/landing':
            return MaterialPageRoute(builder: (_) => Landing());
          case '/ocr':
            return MaterialPageRoute(builder: (_) => OcrScreen());
          case '/guideline':
            return MaterialPageRoute(builder: (_) => const GuidelineScreen());
          default:
            return MaterialPageRoute(builder: (_) => LoginScreen());
        }
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
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (widget.firstLogin && !widget.hasSeenGuideline) {
      Navigator.of(context).pushReplacementNamed('/guideline');
    } else {
      Navigator.of(context).pushReplacementNamed('/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
