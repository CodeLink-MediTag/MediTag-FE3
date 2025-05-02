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

                final request = SignupRequestModel(
                  username: _username,
                  password: _password,
                  name: _name,
                  phoneNumber: _phoneNumber,
                  firebaseToken: "",
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
                    const SnackBar(content: Text('회원가입 실패')),
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
