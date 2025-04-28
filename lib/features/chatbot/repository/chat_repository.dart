import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medife/features/chatbot/model/session_creation_request_model.dart';

import '../../../ip/ip_address.dart';

class ChatRepository{
  Future<int?> sessionCreation(SessionCreationRequestModel request) async {

    final res = await http.post(          // 2. 토큰 있으면 채팅 세션id 생성
      Uri.parse('http://$ipAddress:8080/api/chat/session'),
      headers: {
        'Authorization': 'Bearer ${request.accessToken}',
      },
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final chatSessionId = data['id'];            // 3. 세션 id 변수에 넣어놓기
      return chatSessionId;
    } else {
      print('세션 생성 실패: ${res.body}');
      return null;
    }
  }
}