// login_screen.dart
import 'package:flutter/material.dart';
import '../component/login_fields.dart';
import '../component/login_logo.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const LoginLogo(), // 앱 로고

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      LoginFields(), // 폼 입력 및 버튼
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
