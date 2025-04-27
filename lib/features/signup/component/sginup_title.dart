import 'package:flutter/cupertino.dart';

class SignupTitle extends StatelessWidget {
  const SignupTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      '회원가입',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}