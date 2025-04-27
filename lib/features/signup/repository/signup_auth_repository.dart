import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medife/ip/ip_address.dart';

import '../model/signup_request_model.dart';  // 새로 만든 모델 import

class SignupAuthRepository {

  Future<bool> signup(SignupRequestModel request) async {
    final response = await http.post(
      Uri.parse('http://$ipAddress:8080/api/member/register'), // 회원가입 API 경로
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) { // 보통 회원가입은 201 Created로 응답
      print(response.body);
      return true;
    } else {
      print(response.body);
      return false;
    }
  }
}
