import 'package:flutter/material.dart';

class VoiceRecordButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const VoiceRecordButton({
    required this.isListening,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 70,
      left: 0,
      right: 0,
      child: Center(
        child: FloatingActionButton(
          backgroundColor: Color(0xFF547EE8),
          onPressed: onPressed,
          child: Icon(
            isListening ? Icons.mic_off : Icons.mic,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
