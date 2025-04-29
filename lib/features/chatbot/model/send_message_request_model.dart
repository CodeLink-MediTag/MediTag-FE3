class SendMessageRequestModel{
  final String accessToken;
  final int sessionId;
  final String content;
  final String sender;

  SendMessageRequestModel({
    required this.accessToken,
    required this.sessionId,
    required this.content,
    this.sender = "USER"
  });

  // JSON으로 변환 (서버 요청용)
  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'content': content,
    };
  }


}