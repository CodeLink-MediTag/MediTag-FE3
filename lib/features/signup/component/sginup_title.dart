import 'package:flutter/material.dart';

class SignupTitle extends StatelessWidget {
  const SignupTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // 배경 흰색
      alignment: Alignment.center, // 가운데 정렬
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: const Text(
        '회원가입',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black, // 텍스트 색상
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
