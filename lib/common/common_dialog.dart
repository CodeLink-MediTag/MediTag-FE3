import 'package:flutter/material.dart';

class CommonDialog {
  static Future<void> showCompletedDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: onConfirm,
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
