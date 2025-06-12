import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medife/ip/ip_address.dart';

class GuardianResponse {
  final int id;
  final String phoneNumber;
  final String relationship;

  GuardianResponse({
    required this.id,
    required this.phoneNumber,
    required this.relationship,
  });

  factory GuardianResponse.fromJson(Map<String, dynamic> json) {
    // JSON 키가 "id" 로 내려오므로 여기를 수정합니다.
    final rawId = json['id'] ?? json['guardianId'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId.toString()) ?? 0;

    return GuardianResponse(
      id: parsedId,
      phoneNumber: json['phoneNumber'] as String,
      relationship: json['relationship'] as String,
    );
  }
}

class GuardianApi {
  final _base = 'http://$ipAddress:8080/api/guardians';

  Future<GuardianResponse> register(String token, String phone, String relation) async {
    final res = await http.post(
      Uri.parse(_base),
      headers: {
        'Content-Type':'application/json',
        'Authorization':'Bearer $token'
      },
      body: jsonEncode({'phoneNumber': phone, 'relationship': relation}),
    );
    if (res.statusCode == 200) {
      return GuardianResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('보호자 등록 실패(${res.statusCode})');
  }

  Future<List<GuardianResponse>> fetchAll(String token) async {
    final res = await http.get(
      Uri.parse(_base),
      headers: {'Authorization':'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => GuardianResponse.fromJson(e)).toList();
    }
    throw Exception('보호자 목록 조회 실패(${res.statusCode})');
  }

  Future<void> delete(String token, int id) async {
    final res = await http.delete(
      Uri.parse('$_base/$id'),
      headers: {'Authorization':'Bearer $token'},
    );
    if (res.statusCode != 200) {
      throw Exception('보호자 삭제 실패(${res.statusCode})');
    }
  }
}
