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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      // 입력 영역 배경은 테마의 surface (카드/패널) 색 사용
      color: cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: '메시지 입력...',
                filled: true,
                // 입력박스 내부 색은 surfaceVariant가 있으면 사용 (더 연한 패널 색)
                fillColor: cs.surfaceVariant ?? cs.surface.withOpacity(0.95),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: theme.dividerColor,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.6)),
              ),
              onSubmitted: (value) => onSend(value),
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            label: '메시지 전송',
            button: true,
            child: IconButton(
              icon: Icon(Icons.send, color: cs.primary),
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
