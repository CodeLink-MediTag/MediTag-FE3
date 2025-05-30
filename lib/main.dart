import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // provider 패키지 추가
import 'package:medife/providers/text_size_provider.dart';

import 'features/login/screen/login_screen.dart';
import 'features/signup/screen/signup_screen.dart';
import 'screens/landing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko_KR', null);  // 한국어 날짜 포맷 초기화
  KakaoSdk.init(nativeAppKey: 'YOUR_NATIVE_APP_KEY');  // 카카오 SDK 초기화 (KEY 넣어야 함)

  runApp(
    ChangeNotifierProvider(
      create: (_) => TextSizeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textSize = context.watch<TextSizeProvider>().textSize;

    return MaterialApp(
      title: 'MediTag',
      theme: ThemeData(
        fontFamily: 'SEBANGGothic',
        primarySwatch: Colors.blue,
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: textSize / 14.0,  // textSize 14 기준 배율 적용
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/landing': (context) => Landing(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
