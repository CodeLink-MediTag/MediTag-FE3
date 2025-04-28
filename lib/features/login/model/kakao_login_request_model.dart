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