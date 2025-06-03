import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  await initializeDateFormatting('ko_KR', null);
  KakaoSdk.init(nativeAppKey: 'YOUR_NATIVE_APP_KEY');

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
    return MaterialApp(
      title: 'MediTag',
      theme: ThemeData(
        fontFamily: 'SEBANG',
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) {
        final textSizeProvider = context.watch<TextSizeProvider>();

        final double textSize = (textSizeProvider.textSize != null && textSizeProvider.textSize > 0)
            ? textSizeProvider.textSize
            : 14.0;

        // textScaleFactor로 전체 텍스트 크기 조정
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
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
