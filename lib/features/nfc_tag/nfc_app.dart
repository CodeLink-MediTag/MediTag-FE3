import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      routes: {
        '/morning': (_) => MorningScreen(),
        '/lunch': (_) => LunchScreen(),
        '/dinner': (_) => DinnerScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialNfcLaunch();   // 앱 실행 시 NFC 인텐트 확인
    _startNfcSession();         // 앱 실행 중에도 NFC 감지
  }

  // 앱이 NFC 태그로 실행됐는지 확인
  Future<void> _checkInitialNfcLaunch() async {
    const platform = MethodChannel('nfc_channel');
    try {
      final String? cardInfo = await platform.invokeMethod('getInitialNfcData');
      if (cardInfo != null && cardInfo.isNotEmpty) {
        _navigateToTimeScreen(cardInfo);
      }
    } catch (e, st) {
      debugPrint("초기 NFC 데이터 없음 (안전처리): $e\n$st");
    }
  }


  void _startNfcSession() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      final ndef = Ndef.from(tag);
      if (ndef == null) return;

      final message = await ndef.read();
      if (message.records.isNotEmpty) {
        final payload = message.records.first.payload;
        int langCodeLen = payload.first;
        String cardInfo = String.fromCharCodes(payload.sublist(1 + langCodeLen));

        _navigateToTimeScreen(cardInfo);
      }
      NfcManager.instance.stopSession();
    });
  }

  void _navigateToTimeScreen(String cardInfo) {
    if (cardInfo == "morning_card") {
      Navigator.pushNamed(context, '/morning');
    } else if (cardInfo == "lunch_card") {
      Navigator.pushNamed(context, '/lunch');
    } else if (cardInfo == "dinner_card") {
      Navigator.pushNamed(context, '/dinner');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("NFC 카드를 태그하세요")),
    );
  }
}


class MorningScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("아침 약 복용")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text("복용했어요 ✅"),
        ),
      ),
    );
  }
}

class LunchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("점심 약 복용")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text("복용했어요 ✅"),
        ),
      ),
    );
  }
}

class DinnerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("저녁 약 복용")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text("복용했어요 ✅"),
        ),
      ),
    );
  }
}
