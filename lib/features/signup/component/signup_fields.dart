
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SignupTextField(
            label: '아이디',
            validator: (value) => value!.isEmpty ? '아이디를 입력해주세요' : null,
            onSaved: (value) => _username = value!,
          ),
          const SizedBox(height: 20),
          SignupTextField(
            label: '이름',
            validator: (value) => value!.isEmpty ? '이름을 입력해주세요' : null,
            onSaved: (value) => _name = value!,
          ),
          const SizedBox(height: 20),
          SignupTextField(
            label: '전화번호',
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? '전화번호를 입력해주세요' : null,
            onSaved: (value) => _phoneNumber = value!,
          ),
          const SizedBox(height: 20),
          SignupTextField(
            label: '비밀번호',
            obscureText: true,
            validator: (value) => value!.isEmpty ? '비밀번호를 입력해주세요' : null,
            onSaved: (value) => _password = value!,
          ),
          const SizedBox(height: 32),
          SignupButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                try{
                  // 파이어베이스 토큰 가져오기
                  final firebaseToken = await getFCMToken();
                  final request = SignupRequestModel(
                      username: _username,
                      password: _password,
                      name: _name,
                      phoneNumber: _phoneNumber,
                      firebaseToken: firebaseToken // 아직 파이어베이스 토큰 받는 기능이 없음으로 빈 문자열 삽입
                  );
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
              }
            },
          ),
        ],
      ),
    );
  }

  Future<String> getFCMToken() async {
    try {
      // 권한 요청 (Android 13 이상 또는 iOS 필요)
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('🚫 알림 권한이 거부되었습니다.');
        throw Exception('알림 권한이 필요합니다.');
      }
      // 토큰 가져오기
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        print('⚠️ FCM 토큰이 null입니다.');
        throw Exception('FCM 토큰을 가져오지 못했습니다.');
      }

      print('📌 FCM Token: $token'); // 콘솔 출력
      return token.toString();
    } catch (e) {
      print('❌ FCM 토큰 가져오기 실패: $e');
      throw Exception('토큰 가져오기 실패 $e');
    }
  }
}
