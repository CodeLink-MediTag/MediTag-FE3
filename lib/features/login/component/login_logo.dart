import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24),
        // 로고 이미지 들어갈 자리
        SizedBox(
          height: 100,
        ),
        const SizedBox(height: 16),
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