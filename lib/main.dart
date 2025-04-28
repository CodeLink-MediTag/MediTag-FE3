import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medife/features/signup/old_sign_up.dart';
import 'package:medife/screens/landing.dart'; // 시작화면
import 'package:medife/routes/route_observer.dart';

import 'features/login/screen/login_screen.dart';
import 'features/signup/screen/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediTag',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // 시작화면
      routes: {
        '/': (context) => LoginScreen(),      // 첫 화면
        '/login': (context) => LoginScreen(), // 로그인 화면
        '/signup': (context) => SignupScreen(),   // 회원가입 화면
        '/landing': (context) => Landing(), // 홈 화면
        // 추가 화면들도 여기에 등록
      },      debugShowCheckedModeBanner: false,
    );
  }
}
