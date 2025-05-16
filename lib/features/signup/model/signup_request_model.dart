class SignupRequestModel {
  final String username;
  final String password;
  final String name;
  final String phoneNumber;
  final String? firebaseToken;

  SignupRequestModel({
    required this.username,
    required this.password,
    required this.name,
    required this.phoneNumber,
    required this.firebaseToken
  });


  /// JSON으로 변환 (서버 요청용)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'name': name,
      'phone': phoneNumber,
      'firebasetoken': firebaseToken
    };
  }
}
