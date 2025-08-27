// lib/features/mypage/unregister/unregister_button.dart
import 'package:flutter/material.dart';

class UnregisterButton extends StatelessWidget {
  final VoidCallback onPressed;
  const UnregisterButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        onPressed: onPressed,
        child: const Text('계정 삭제(탈퇴)', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
