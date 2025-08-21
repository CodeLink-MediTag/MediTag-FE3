import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LunchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('점심 약 복용')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 서버 또는 로컬 DB에 복용 완료 저장
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('복용 완료')));
          },
          child: Text('복용했어요'),
        ),
      ),
    );
  }
}
