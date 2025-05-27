import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:medife/common/common_dialog.dart';
import 'package:medife/features/signup/component/signup_button.dart';
import 'package:medife/features/signup/component/signup_text_field.dart';

import '../model/signup_request_model.dart';
import '../repository/signup_auth_repository.dart';

class SignupFields extends StatelessWidget {
  final repository = SignupAuthRepository();
  final _formKey = GlobalKey<FormState>();

  String _username = '';
  String _password = '';
  String _name = '';
  String _phoneNumber = '';

  SignupFields({super.key});

  Future<String> getFCMToken() async {
    // 권한 요청
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
          SignupTextField(
            label: '비밀번호',
            controller: TextEditingController(text: "test12345"),
            obscureText: true,
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
                // 실패 시 빈 문자열로 대체
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
                    Navigator.of(context).pop(); // 다이얼로그 닫고
                    Navigator.of(context).pop(); // 이전 화면으로
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

/*
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:medife/common/common_dialog.dart';
import 'package:medife/features/signup/component/signup_button.dart';
import 'package:medife/features/signup/component/signup_text_field.dart';
import '../model/signup_request_model.dart';
import '../repository/signup_auth_repository.dart';

class SignupFields extends StatefulWidget {
  const SignupFields({Key? key}) : super(key: key);

  @override
  _SignupFieldsState createState() => _SignupFieldsState();
}

class _SignupFieldsState extends State<SignupFields> {
  final _formKey = GlobalKey<FormState>();
  final _repository = SignupAuthRepository();

  String _username = '';
  String _password = '';
  String _name = '';
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    // ScaffoldMessenger를 미리 캡처
    final messenger = ScaffoldMessenger.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          SignupTextField(
            label: '아이디',
            controller: TextEditingController(text: "test@gmail.com"),
            validator: (value) =>
            value!.isEmpty ? '아이디를 입력해주세요' : null,
            onSaved: (value) => _username = value!,
          ),
          const SizedBox(height: 20),
          SignupTextField(
            label: '이름',
            controller: TextEditingController(text: "회원1"),
            validator: (value) =>
            value!.isEmpty ? '이름을 입력해주세요' : null,
            onSaved: (value) => _name = value!,
          ),
          const SizedBox(height: 20),
          SignupTextField(
            label: '전화번호',
            controller: TextEditingController(text: "010-1234-5678"),
            keyboardType: TextInputType.phone,
            validator: (value) =>
            value!.isEmpty ? '전화번호를 입력해주세요' : null,
            onSaved: (value) => _phoneNumber = value!,
          ),
          const SizedBox(height: 20),
          SignupTextField(
            label: '비밀번호',
            controller: TextEditingController(text: "test12345"),
            obscureText: true,
            validator: (value) =>
            value!.isEmpty ? '비밀번호를 입력해주세요' : null,
            onSaved: (value) => _password = value!,
          ),
          const SizedBox(height: 32),
          SignupButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();

              // 1) FCM 토큰 얻기
              String fcmToken;
              try {
                fcmToken = await _getFcmToken();
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('토큰 획득 실패: ${e.toString()}')),
                );
                return;
              }

              // 2) 가입 요청
              final request = SignupRequestModel(
                username: _username,
                password: _password,
                name: _name,
                phoneNumber: _phoneNumber,
                firebaseToken: fcmToken,
              );

              try {
                await _repository.signup(request);
                if (!mounted) return;
                CommonDialog.showCompletedDialog(
                  context: context,
                  title: '회원가입 성공',
                  content: '회원가입이 완료되었습니다.',
                  onConfirm: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    Navigator.of(context).pop(); // 가입 화면 닫기
                  },
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('회원가입 실패: ${e.toString()}')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<String> _getFcmToken() async {
    // 권한 요청 (Android 13 이상 / iOS)
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      throw Exception('알림 권한이 거부되었습니다.');
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      throw Exception('FCM 토큰을 받아오지 못했습니다.');
    }

    return token;
  }
}


 */