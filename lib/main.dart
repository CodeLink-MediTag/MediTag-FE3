import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medife/screens/landing.dart'; // 시작화면
import 'package:medife/routes/route_observer.dart';

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
      home: const Landing(),
      navigatorObservers: [routeObserver], // ✅ 이 줄 추가: RouteObserver 등록
      debugShowCheckedModeBanner: false,
    );
  }
}
