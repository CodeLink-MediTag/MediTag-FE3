import 'package:flutter/material.dart';
import 'package:medife/ip/ip_address.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medife/components/custom_app_bar.dart';

class ChatBot extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ScrollController _scrollController = ScrollController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '말을 시작해보세요!';
  String? _accessToken;
  int? _chatSessionId;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadTokenAndStartSession();
  }

  Future<void> _loadTokenAndStartSession() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('token');

    final res = await http.post(
      Uri.parse('http://$ipAddress:8080/api/chat/session'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      _chatSessionId = data['id'];
    } else {
      print('세션 생성 실패: ${res.body}');
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            if (val.hasConfidenceRating && val.confidence > 0) {
              setState(() {
                _isListening = false;
                _speech.stop();
              });
              _sendMessageToServer(val.recognizedWords);
            }
          },
          localeId: 'ko_KR',
          listenMode: stt.ListenMode.dictation,
          pauseFor: Duration(seconds: 3),
          partialResults: false,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _sendMessageToServer(String userMessage) async {
    if (_chatSessionId == null || _accessToken == null) return;

    setState(() {
      messages.add({'type': 'user', 'text': userMessage});
    });

    final res = await http.post(
      Uri.parse('http://$ipAddress:8080/api/chat/message/$_chatSessionId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'sender': 'USER', 'content': userMessage}),
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        messages.add({'type': 'bot', 'text': data['content']});
        _scrollToBottom();
      });
    } else {
      print('서버 응답 실패: ${res.body}');
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: Stack(
        children: [
          Column(
            children: [
              CustomAppBar(title: '챗봇'),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return msg['type'] == 'user'
                        ? _buildUserMessage(msg['text']!)
                        : _buildBotMessage(msg['text']!);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        textField: true,
                        label: '메시지 입력 필드',
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: '메시지 입력...',
                            filled: true,
                            fillColor: Color(0xFFF6F6F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (value) {
                            _sendMessageToServer(value);
                            _controller.clear();
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Semantics(
                      button: true,
                      label: '메시지 보내기',
                      child: IconButton(
                        icon: Icon(Icons.send, color: Color(0xFF547EE8)),
                        onPressed: () {
                          _sendMessageToServer(_controller.text);
                          _controller.clear();
                        },
                        tooltip: '메시지 보내기',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                tooltip: _isListening ? '음성입력하기 취소' : '음성입력하기',
                backgroundColor: Color(0xFF547EE8),
                onPressed: _listen,
                child: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFDADADA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBotMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF547EE8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '음성답변',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
