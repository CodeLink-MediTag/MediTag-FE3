import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medife/ip/ip_address.dart';

import '../model/signup_request_model.dart';  // 새로 만든 모델 import

class SignupAuthRepository {

  Future<bool> signup(SignupRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress/api/member/register'), // 회원가입 API 경로  Uri.parse('http://$ipAddress:8080/api/member/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(json['message']);
      }
    }catch(e){
      throw Exception('회원가입 실패:  $e');
    }
  }
}
