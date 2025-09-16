import 'package:flutter/material.dart';

class SignupTitle extends StatelessWidget {
  const SignupTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      // 배경은 스크린 배경을 따르도록 하지 않습니다. (ListView의 배경과 자연스럽게 어우러짐)
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        '회원가입',
        textAlign: TextAlign.center,
        style: t.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onBackground,
        ),
      ),
    );
  }
}
