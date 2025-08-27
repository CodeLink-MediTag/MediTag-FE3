// lib/features/mypage/unregister/unregister_password_dialog.dart
import 'package:flutter/material.dart';

class UnregisterPasswordDialog {
  /// 호출 예시:
  /// final pw = await UnregisterPasswordDialog.show(context);
  static Future<String?> show(BuildContext ctx) {
    final ctrl = TextEditingController();

    return showDialog<String>(
      context: ctx,
      barrierDismissible: false,
      builder: (dctx) {
        bool obscure = true;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('비밀번호 확인'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('탈퇴를 진행하려면 비밀번호를 다시 입력해주세요.'),
                  const SizedBox(height: 12),
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, size: 28, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            obscureText: obscure,
                            obscuringCharacter: '*',
                            autofocus: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(letterSpacing: 6, fontSize: 18),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: '',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => obscure = !obscure),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dctx).pop(null), child: const Text('취소')),
                TextButton(onPressed: () => Navigator.of(dctx).pop(ctrl.text.trim()), child: const Text('확인')),
              ],
            );
          },
        );
      },
    );
  }
}
