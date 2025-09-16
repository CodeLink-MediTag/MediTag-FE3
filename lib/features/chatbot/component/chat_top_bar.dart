import 'package:flutter/material.dart';

class ChatTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onHome;

  const ChatTopBar({required this.onBack, required this.onHome, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      color: cs.primary, // 테마의 primary 사용
      padding: const EdgeInsets.only(top: 37, bottom: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onPrimary),
            onPressed: onBack,
          ),
          Expanded(
            child: Center(
              child: Text(
                '챗봇',
                style: theme.textTheme.titleLarge?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.home, color: cs.onPrimary),
            onPressed: onHome,
          ),
        ],
      ),
    );
  }
}
