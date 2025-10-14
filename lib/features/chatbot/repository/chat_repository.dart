import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medife/features/chatbot/model/send_message_request_model.dart';
import 'package:medife/features/chatbot/model/session_creation_request_model.dart';

import '../../../ip/ip_address.dart';

class ChatRepository{
  Future<int?> sessionCreation(SessionCreationRequestModel request) async {

    try {
      final res = await http.post(
        Uri.parse('http://$ipAddress/api/chat/session'),
        headers: {
          'Authorization': 'Bearer ${request.accessToken}',
        },
      );
      final json = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final chatSessionId = json['id'];
        return chatSessionId;
      } else {
        throw Exception(json['message']);
      }
    }catch(e){
      throw Exception('채팅 세션 생성 실패: $e');
    }
  }

  Future<String> sendMessage(SendMessageRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress/api/chat/message/${request.sessionId}'),
        headers: {
          'Authorization': 'Bearer ${request.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sender': 'USER',
          'content': request.content,
        }),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return json['content'];
      } else {
        throw Exception(json['message']);
      }
    } catch (e){
      throw Exception('메시지 전송 실패: $e');
    }
  }
}