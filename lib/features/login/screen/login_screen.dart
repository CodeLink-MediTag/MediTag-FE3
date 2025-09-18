// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../component/login_fields.dart';
import '../component/login_logo.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const LoginLogo(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      LoginFields(), // 내부에서 로그인 후 이동 처리
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
