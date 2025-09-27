// lib/features/nfc_tag/medicine_screen.dart
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../main.dart';

class MedicineScreen extends StatefulWidget {
  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  String _status = "NFC 태그를 준비하세요";

  Future<void> _writeNfcTag(String text) async {
    setState(() {
      _status = "NFC 태그에 '$text' 작성 중...";
    });

    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        _status = "NFC 사용 불가";
      });
      return;
    }

    // 전역 세션(main.dart) 정지
    await NfcManager.instance.stopSession();

    // 쓰기 세션 시작
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            setState(() {
              _status = "NDEF 형식의 쓰기 가능한 태그가 아닙니다.";
            });
            NfcManager.instance.stopSession(errorMessage: '쓰기 불가');
            return;
          }

          final ndefMessage = NdefMessage([
            NdefRecord.createText(text),
          ]);

          await ndef.write(ndefMessage);

          setState(() {
            _status = "NFC 태그에 '$text' 작성 완료!";
          });

          // 쓰기 완료 후 stopSession()
          await NfcManager.instance.stopSession();

          Future.delayed(const Duration(milliseconds: 500), () {
            GlobalNfcController.startGlobalNfc(); // <-- 이제 이 이름으로 호출
          });


        } catch (e) {
          setState(() {
            _status = "에러 발생: $e";
          });
          NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("약 복용 NFC 설정")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_status,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _writeNfcTag("/morning"),
              child: Text("아침 카드 (/morning)"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _writeNfcTag("/lunch"),
              child: Text("점심 카드 (/lunch)"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _writeNfcTag("/dinner"),
              child: Text("저녁 카드 (/dinner)"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
