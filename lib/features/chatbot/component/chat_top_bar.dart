import 'package:flutter/material.dart';

class ChatTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onHome;

  const ChatTopBar({required this.onBack, required this.onHome, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF547EE8),
      padding: EdgeInsets.only(top: 37, bottom: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
          ),
          Expanded(
            child: Center(
              child: Text(
                '챗봇',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: onHome,
          ),
        ],
      ),
    );
  }
}
