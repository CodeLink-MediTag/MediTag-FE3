import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medife/ip/ip_address.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/login_request_model.dart';


class LoginAuthRepository {

  Future<String?> login(LoginRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:8080/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', json['accessToken']);
        await prefs.setString('refreshToken', json['refreshToken']);
        return json['accessToken'];
      } else {
        // 실패했을 때는 에러를 던진다
        throw Exception(json['message']);
      }
    } catch (e) {
      throw Exception('로그인 실패: $e');
    }
  }
}
