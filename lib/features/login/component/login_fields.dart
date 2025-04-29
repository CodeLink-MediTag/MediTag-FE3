import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../model/kakao_login_request_model.dart';
import '../model/login_request_model.dart';
import '../repository/login_auth_repository.dart';
import 'login_custom_button.dart';
import 'login_custom_text_field.dart';

class LoginFields extends StatelessWidget {

  // 요청 보내는 로직이 있는 리포지토리
  final repository = LoginAuthRepository();

  final formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  LoginFields({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
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
                username = value!;
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
                password = value!;
              },
            ),
            LoginCustomButton(
              text: '로그인',
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final request = LoginRequestModel(username: username, password: password);

                  try {
                    final token = await repository.login(request);
                    print('로그인 성공 $token');
                    Navigator.pushNamed(context, '/landing'); // 홈 화면으로 이동
                  } catch(e){
                    // 로그인 실패 시 처리
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                    );
                  }
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
            const SizedBox(height: 12),
            LoginCustomButton(
              text: '카카오 로그인',
              onPressed: () async {
                final token = await handleKakaoLogin(context);
                final request = KakaoLoginRequestModel(accessToken: token.toString());
                try {
                  final token = await repository.kakaoLogin(request);
                  print('로그인 성공 $token');
                  Navigator.pushNamed(context, '/landing'); // 홈 화면으로 이동
                } catch(e){
                  // 로그인 실패 시 처리
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                  );
                }

              },
            ),
          ],
        )
    );
  }

  Future<String?> handleKakaoLogin(BuildContext context) async {
    String returnToken;
    KakaoSdk.init(
      nativeAppKey: '0294f90ad4d3deac240d0065da6d5c5f', // 카카오 네이티브 앱 키
    );
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;

      if (isInstalled) {
        try {
          // 카카오톡으로 로그인
          token = await UserApi.instance.loginWithKakaoTalk();
          print('✅ 카카오톡으로 로그인 성공: ${token.accessToken}');
        } catch(e){
          print('⚠️ 카카오톡 로그인 실패, 카카오계정으로 로그인 시도: $e');
          // 카카오톡 로그인 실패하면 카카오 계정으로 로그인
          token = await UserApi.instance.loginWithKakaoAccount();
          print('✅ 카카오 계정으로 로그인 성공: ${token.accessToken}');
        }
      } else {
        // 카카오 계정으로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
        print('✅ 카카오 계정으로 로그인 성공: ${token.accessToken}');
      }
      // 사용자 정보 가져오기
      User user = await UserApi.instance.me();
      print('🔹 닉네임: ${user.kakaoAccount?.profile?.nickname}');
      print('🔹 이메일: ${user.kakaoAccount?.email}');
      print('🔹 프로필 사진: ${user.kakaoAccount?.profile?.profileImageUrl}');
      print('🔹 성별: ${user.kakaoAccount?.gender}');
      print('🔹 연령대: ${user.kakaoAccount?.ageRange}');
      returnToken = token.accessToken;
      return returnToken;
    } catch (e) {
      print('❌ 카카오 로그인 실패: $e');
      return null;
    }
  }
}