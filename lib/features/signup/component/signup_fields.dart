import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medife/common/common_dialog.dart';
import 'package:medife/features/signup/component/signup_button.dart';
import 'package:medife/features/signup/component/signup_text_field.dart';

import '../model/signup_request_model.dart';
import '../repository/signup_auth_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignupFields extends StatelessWidget {
  final repository = SignupAuthRepository();

  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _name = '';
  String _phoneNumber = '';
  String? firebaseToken;

  SignupFields({super.key});

  Future<String?> getFirebaseToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      return token;
    } catch (e) {
      print('Firebase 토큰 가져오기 실패: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SignupTextField(
            controller: TextEditingController(text: "test@gmail.com"),
            label: '아이디',
            validator: (value) => value!.isEmpty ? '아이디를 입력해주세요' : null,
            onSaved: (value) => _username = value!,
          ),
          SizedBox(height: 20,),
          SignupTextField(
            controller: TextEditingController(text: "test12345"),
            label: '비밀번호',
            validator: (value) => value!.isEmpty ? '아이디를 입력해주세요' : null,
            onSaved: (value) => _password = value!,
          ),
          SizedBox(height: 20,),
          SignupTextField(
            controller: TextEditingController(text: "회원1"),
            label: '이름',
            validator: (value) => value!.isEmpty ? '아이디를 입력해주세요' : null,
            onSaved: (value) => _name = value!,
          ),
          SizedBox(height: 20,),
          SignupTextField(
            controller: TextEditingController(text: "010-1234-5678"),
            label: '전화번호',
            validator: (value) => value!.isEmpty ? '아이디를 입력해주세요' : null,
            onSaved: (value) => _phoneNumber = value!,
          ),

          SizedBox(height: 20,),
          SignupButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                firebaseToken = await getFirebaseToken();
                print('파이어베이스 토큰 : $firebaseToken'); //확인 해야돼서 넣어야함

                final request = SignupRequestModel(
                  username: _username,
                  password: _password,
                  name: _name,
                  phoneNumber: _phoneNumber,
                  firebaseToken: "" // 아직 파이어베이스 토큰 받는 기능이 없음으로 빈 문자열 삽입
                );

                try{
                  await repository.signup(request);
                  CommonDialog.showCompletedDialog(
                    context: context,
                    title: '회원가입 성공',
                    content: '회원가입이 완료되었습니다.',
                    onConfirm: (){
                      Navigator.of(context).pop(); // 팝업창 pop
                      Navigator.of(context).pop(); // 회원가입 페이지 pop
                    }
                  );
                } catch(e){
                  // 회원가입 실패 처리
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('회원가입 실패')),
                  );
                }

              }
            },
          ),
        ],
      ),
    );
  }
}
