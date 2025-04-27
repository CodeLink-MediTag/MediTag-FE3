import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/login_request_model.dart';
import '../repository/login_auth_repository.dart';
import 'login_custom_button.dart';
import 'login_custom_text_field.dart';

class LoginFields extends StatelessWidget {

  // 요청 보내는 로직이 있는 리포지토리
  final repository = LoginAuthRepository();

  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  LoginFields({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            LoginCustomTextField(
              controller: TextEditingController(text: "test@gmail.com"),
              hintText: '아이디',
              validator: (value){
                return value!.isEmpty
                    ? '아이디를 입력해주세요'
                    : null;
              },
              onSaved: (value){
                _username = value!;
              },
            ),
            const SizedBox(height: 12),
            LoginCustomTextField(
              controller: TextEditingController(text: "test12345"),
              hintText: '비밀번호',
              obscureText: true,
              validator: (value){
                return value!.isEmpty
                    ? '비밀번호를 입력해주세요'
                    : null;
              },
              onSaved: (value){
                _password = value!;
              },
            ),
            LoginCustomButton(
              text: '로그인',
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final request = LoginRequestModel(username: _username, password: _password);
                  final token = await repository.login(request);
                  if (token != null) {
                    // 로그인 성공 시 처리
                    // Navigator.pushNamed(context, '/home');
                    print(token);
                  } else {
                    // 로그인 실패 처리
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인 실패')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            LoginCustomButton(
              text: '회원가입',
              onPressed: () {},
            ),
          ],
        )
    );
  }
}