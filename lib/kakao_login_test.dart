import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    home: Center(
      child: ElevatedButton(
        onPressed: () async {
          final kakaoService = KakaoLoginService();
          final token = await kakaoService.kakaoLogin();

          if (token != null) {
            // 서버로 토큰 보내서 회원가입 or 로그인 처리
            print('토큰: $token');
          } else {
          }
        },
        child: const Text('카카오로 로그인하기'),
      )

    ),
  ));
}
class KakaoLoginService {
  KakaoLoginService() {
    KakaoSdk.init(
      nativeAppKey: '0294f90ad4d3deac240d0065da6d5c5f',
    );
  }

  Future<String?> kakaoLogin() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled(); // 카카오톡 설치 여부 확인
      OAuthToken token;

      try {
        if (isInstalled) {
          token = await UserApi.instance.loginWithKakaoTalk();
          print('✅ 카카오톡으로 로그인 성공: ${token.accessToken}');
        } else {
          token = await UserApi.instance.loginWithKakaoAccount();
          print('✅ 카카오 계정으로 로그인 성공: ${token.accessToken}');
        }
      } catch (e) {
        print('⚠️ 카카오톡 로그인 실패, 계정 로그인으로 재시도: $e');
        token = await UserApi.instance.loginWithKakaoAccount();
        print('✅ 카카오 계정으로 로그인 성공: ${token.accessToken}');
      }

      // ✅ 사용자 정보 가져오기
      User user = await UserApi.instance.me();
      print('🔹 닉네임: ${user.kakaoAccount?.profile?.nickname}');
      print('🔹 이메일: ${user.kakaoAccount?.email}');
      print('🔹 프로필 사진: ${user.kakaoAccount?.profile?.profileImageUrl}');
      print('🔹 성별: ${user.kakaoAccount?.gender}');
      print('🔹 연령대: ${user.kakaoAccount?.ageRange}');



    } catch (error) {
      print('❌ 로그인 실패: $error');
    }
  }
}

