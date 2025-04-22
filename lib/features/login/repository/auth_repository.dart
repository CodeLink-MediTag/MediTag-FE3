import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/login_request_model.dart';


class AuthRepository {
  Future<String?> login(LoginRequestModel request) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.11:8080/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', json['accessToken']);
      await prefs.setString('refreshToken', json['refreshToken']);
      return json['accessToken'];
    } else {
      print(response.body);
      return null;
    }
  }
}
