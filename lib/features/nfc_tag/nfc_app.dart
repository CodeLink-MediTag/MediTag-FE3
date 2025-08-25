

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
