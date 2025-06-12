// login_fields.dart
import 'package:flutter/material.dart';
import 'package:medife/screens/landing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:medife/screens/guideline/guideline_screen.dart';
import 'package:medife/routes/route_names.dart';

import 'login_custom_button.dart';
import 'login_custom_text_field.dart';
import '../model/login_request_model.dart';
import '../model/kakao_login_request_model.dart';
import '../repository/login_auth_repository.dart';

class LoginFields extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginFields({super.key, this.onLoginSuccess});

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  final repository = LoginAuthRepository();
  final formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';

  Future<void> _handleLoginSuccess() async {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Landing()),
    );

    /*
    final prefs = await SharedPreferences.getInstance();
    bool hasSeenGuideline = prefs.getBool('hasSeenGuideline') ?? false;

    if (hasSeenGuideline) {
      Navigator.pushReplacementNamed(context, RouteName.landing);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GuidelineScreen()),
      );
    }

     */
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text('아이디', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          LoginCustomTextField(
            controller: TextEditingController(text: "test@gmail.com"),
            hintText: 'ID',
            validator: (value) => value!.isEmpty ? '아이디를 입력해주세요' : null,
            onSaved: (value) => username = value!,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          const Text('비밀번호', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          LoginCustomTextField(
            controller: TextEditingController(text: "test12345"),
            hintText: 'password',
            obscureText: true,
            validator: (value) => value!.isEmpty ? '비밀번호를 입력해주세요' : null,
            onSaved: (value) => password = value!,
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 24),
          LoginCustomButton(
            text: '로그인',
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              formKey.currentState!.save();

              final request = LoginRequestModel(
                  username: username,
                  password: password
              );

              try {
                // 1) 리포지토리에서 토큰 문자열 받아오기
                final token = await repository.login(request);  // String

                // 2) SharedPreferences에 username만 저장
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('username', username);

                // 3) 다음 화면으로
                await _handleLoginSuccess();

                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
            },
          ),
          const SizedBox(height: 12),
          LoginCustomButton(
            text: '카카오 로그인',
            backgroundColor: const Color(0xFFFEE500),
            textColor: Colors.black,
            onPressed: () async {
              final token = await handleKakaoLogin(context);
              if (token == null) return;

              final request = KakaoLoginRequestModel(accessToken: token);
              try {
                final response = await repository.kakaoLogin(request);
                print('카카오 로그인 성공: $response');
                await _handleLoginSuccess();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          LoginCustomButton(
            text: '회원가입',
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
          ),
        ],
      ),
    );
  }

  Future<String?> handleKakaoLogin(BuildContext context) async {
    KakaoSdk.init(nativeAppKey: '0294f90ad4d3deac240d0065da6d5c5f');
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;
      if (isInstalled) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (_) {
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      return token.accessToken;
    } catch (e) {
      print('카카오 로그인 실패: $e');
      return null;
    }
  }
}
