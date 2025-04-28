class LoginRequestModel {
  final String username;
  final String password;

  LoginRequestModel({
    required this.username,
    required this.password,
  });

  /// JSON으로 변환 (서버 요청용)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class KakaoLoginRequestModel{
  final String accessToken;

  KakaoLoginRequestModel({
    required this.accessToken
  });

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken
    };
  }
}