import 'package:flutter/material.dart';

class VoiceRecordButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final double? size; // 선택적 크기 지정

  const VoiceRecordButton({
    required this.isListening,
    required this.onPressed,
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double btnSize = size ?? 56.0;

    return SizedBox(
      width: btnSize,
      height: btnSize,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: cs.primary,
        child: Icon(
          isListening ? Icons.mic_off : Icons.mic,
          color: cs.onPrimary,
        ),
      ),
    );
  }
}
