import 'package:flutter/material.dart';

/// “레이블 + 안에 들어가는 위젯” 구조를 공통으로 묶어 주는 재사용 위젯

class EditField extends StatelessWidget {
  final String label;
  final Widget child;

  const EditField({
    Key? key,
    required this.label,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 위에 레이블 텍스트
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        // 실제 입력 위젯(텍스트필드 등)
        child,
      ],
    );
  }
}
