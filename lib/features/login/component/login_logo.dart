import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        SizedBox(
          height: 100,
          child: Image.asset(
            'assets/images/logo.png', // 실제 경로에 따라 수정
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '로그인',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
