class LoginResponseModel {
  final String accessToken;
  final String refreshToken;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  /// JSON 응답을 모델로 변환
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
