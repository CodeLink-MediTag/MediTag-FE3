import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medife/screens/landing.dart'; // 랜딩 화면
import 'package:medife/features/login/screen/login_screen.dart';
import 'package:medife/features/signup/screen/signup_screen.dart';
import 'package:medife/screens/guideline/guideline_screen.dart';  // 가이드라인 화면 import
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkGuidelineSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenGuideline') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkGuidelineSeen(),
      builder: (context, snapshot) {
        // 데이터 준비 전 로딩 화면
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // hasSeenGuideline 값에 따라 초기화면 결정
        bool hasSeenGuideline = snapshot.data ?? false;

        return MaterialApp(
          title: 'MediTag',
          theme: ThemeData(
            fontFamily: 'Pretendard',
            primarySwatch: Colors.blue,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: hasSeenGuideline ? '/landing' : '/guideline',
          routes: {
            '/': (context) => LoginScreen(),      // 첫 화면
            '/login': (context) => LoginScreen(), // 로그인 화면
            '/signup': (context) => SignupScreen(),   // 회원가입 화면
            '/landing': (context) => const Landing(), // 홈 화면
            '/guideline': (context) => const GuidelineScreen(), // 가이드라인 화면
            // 필요 시 추가 화면 등록
          },
        );
      },
    );
  }
}
