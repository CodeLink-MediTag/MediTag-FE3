import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  // true이면 왼쪽(봇), false이면 오른쪽(사용자)
  final bool alignLeft;
  final String message;

  const Message({
    super.key,
    this.alignLeft = true,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 왼쪽(봇)은 primary 계열, 오른쪽(사용자)은 surface 계열 사용
    final bubbleColor = alignLeft ? cs.primary : cs.surface;
    final textColor = alignLeft ? cs.onPrimary : cs.onSurface;

    // 오른쪽(사용자)은 우측 정렬, 왼쪽(봇)은 좌측 정렬
    final alignment = alignLeft ? Alignment.centerLeft : Alignment.centerRight;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ),
    );
  }
}
