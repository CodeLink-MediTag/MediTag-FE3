import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLoginService {
  KakaoLoginService() {
    KakaoSdk.init(
      nativeAppKey: '0294f90ad4d3deac240d0065da6d5c5f', // 카카오 네이티브 앱 키
    );
  }
  Future<OAuthToken?> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;

      if (isInstalled) {
        // 카카오톡으로 로그인
        token = await UserApi.instance.loginWithKakaoTalk();
        print('✅ 카카오톡으로 로그인 성공: ${token.accessToken}');
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

      return token;
    } catch (e) {
      print('❌ 카카오 로그인 실패: $e');
      return null;
    }
  }
}
