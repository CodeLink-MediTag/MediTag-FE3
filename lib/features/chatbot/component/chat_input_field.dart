import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function(String) onSend;

  const ChatInputField({
    required this.controller,
    required this.onSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '메시지 입력...',
                filled: true,
                fillColor: Color(0xFFF6F6F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) => onSend(value),
            ),
          ),
          SizedBox(width: 10),
          Semantics(
            label: '메시지 전송',
            button: true,
            child: IconButton(
              icon: Icon(Icons.send, color: Color(0xFF547EE8)),
              onPressed: () {
                onSend(controller.text);
              },
            ),
          ),
        ],
      ),
    );
  }
}