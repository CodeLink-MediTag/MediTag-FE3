// lib/features/mypage/unregister/unregister_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/ip/ip_address.dart';

enum UnregisterStatus { success, unauthorized, error }

class UnregisterResult {
  final UnregisterStatus status;
  final int code;
  final String message;

  UnregisterResult({required this.status, required this.code, this.message = ''});
}

class UnregisterService {
  /// 비밀번호(optional)를 받아 서버에 DELETE 요청을 보낸다.
  /// 결과를 UnregisterResult로 반환.
  static Future<UnregisterResult> deleteAccount({String? password}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? prefs.getString('token');
      if (token == null || token.isEmpty) {
        return UnregisterResult(status: UnregisterStatus.unauthorized, code: 401, message: '토큰 없음');
      }

      final uri = Uri.parse('http://$ipAddress:8080/api/member/me');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      http.Response res;
      if (password != null && password.isNotEmpty) {
        final body = jsonEncode({'password': password});
        res = await http.delete(uri, headers: headers, body: body);
      } else {
        res = await http.delete(uri, headers: headers);
      }

      final code = res.statusCode;
      if (code == 200 || code == 204) {
        // 성공: 로컬 정보 삭제
        await prefs.clear();
        return UnregisterResult(status: UnregisterStatus.success, code: code);
      } else if (code == 401 || code == 403) {
        await prefs.clear();
        return UnregisterResult(status: UnregisterStatus.unauthorized, code: code, message: res.body);
      } else {
        String msg = res.body;
        try {
          final bodyJson = jsonDecode(res.body);
          if (bodyJson is Map && bodyJson['message'] != null) msg = bodyJson['message'];
        } catch (_) {}
        return UnregisterResult(status: UnregisterStatus.error, code: code, message: msg);
      }
    } catch (e) {
      return UnregisterResult(status: UnregisterStatus.error, code: -1, message: e.toString());
    }
  }
}
