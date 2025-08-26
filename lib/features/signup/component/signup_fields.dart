import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:medife/common/common_dialog.dart';
import 'package:medife/features/signup/component/signup_button.dart';
import 'package:medife/features/signup/component/signup_text_field.dart';

import '../model/signup_request_model.dart';
import '../repository/signup_auth_repository.dart';

class SignupFields extends StatefulWidget {
  SignupFields({super.key});

  @override
  State<SignupFields> createState() => _SignupFieldsState();
}

class _SignupFieldsState extends State<SignupFields> {
  final repository = SignupAuthRepository();
  final _formKey = GlobalKey<FormState>();

  String _username = '';
  String _password = '';
  String _name = '';
  String _phoneNumber = '';

  // 👇 비밀번호 보이기/숨기기 상태 변수 추가
  bool _obscurePassword = true;

  Future<String> getFCMToken() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      throw Exception('알림 권한이 필요합니다.');
    }
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      throw Exception('FCM 토큰을 가져오지 못했습니다.');
    }
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SignupTextField(
            label: '아이디',
            controller: TextEditingController(text: "test@gmail.com"),
            validator: (v) => v!.isEmpty ? '아이디를 입력해주세요' : null,
            onSaved: (v) => _username = v!,
          ),
          const SizedBox(height: 20),
          SignupTextField(
            label: '이름',
            controller: TextEditingController(text: "회원1"),
            validator: (v) => v!.isEmpty ? '이름을 입력해주세요' : null,
            onSaved: (v) => _name = v!,
          ),
          const SizedBox(height: 20),
          SignupTextField(
            label: '전화번호',
            controller: TextEditingController(text: "010-1234-5678"),
            keyboardType: TextInputType.phone,
            validator: (v) => v!.isEmpty ? '전화번호를 입력해주세요' : null,
            onSaved: (v) => _phoneNumber = v!,
          ),
          const SizedBox(height: 20),
          // 👇 비밀번호 필드에 눈 아이콘 토글 기능 추가
          SignupTextField(
            label: '비밀번호',
            controller: TextEditingController(text: "test12345"),
            obscureText: true, // 여기를 true로 고정
            validator: (v) => v!.isEmpty ? '비밀번호를 입력해주세요' : null,
            onSaved: (v) => _password = v!,
          ),
          const SizedBox(height: 32),
          SignupButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();

              // 1) FCM 토큰 얻기 시도
              String fcmToken;
              try {
                fcmToken = await getFCMToken();
              } catch (e) {
                print('❌ FCM 토큰 획득 실패, 빈 문자열로 대체: $e');
                fcmToken = '';
              }

              final request = SignupRequestModel(
                username: _username,
                password: _password,
                name: _name,
                phoneNumber: _phoneNumber,
                firebaseToken: fcmToken,
              );

              try {
                await repository.signup(request);
                CommonDialog.showCompletedDialog(
                  context: context,
                  title: '회원가입 성공',
                  content: '회원가입이 완료되었습니다.',
                  onConfirm: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('회원가입 실패: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}