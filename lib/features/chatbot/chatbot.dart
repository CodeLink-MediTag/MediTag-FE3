import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart';

class ChatBot extends StatefulWidget {
  static const routeName = '/chatbot';

  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add({'type': 'user', 'text': text});
        messages.add({'type': 'bot', 'text': '자동 응답: "$text"에 대한 답변입니다.'});
      });
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          Column(
            children: [
              // 커스텀 앱바 사용
              const CustomAppBar(title: '챗봇'),

              // 메시지 리스트
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return msg['type'] == 'user'
                        ? _buildUserMessage(msg['text']!)
                        : _buildBotMessage(msg['text']!);
                  },
                ),
              ),

              // 입력창 & 버튼
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: '메시지 입력...'
                          ,
                          filled: true,
                          fillColor: const Color(0xFFF6F6F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (value) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF547EE8)),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 중앙 음성 녹음 아이콘
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF547EE8),
                onPressed: () {},
                child: const Icon(Icons.mic, color: Colors.white, size: 28),
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFDADADA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBotMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF547EE8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '음성답변',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
