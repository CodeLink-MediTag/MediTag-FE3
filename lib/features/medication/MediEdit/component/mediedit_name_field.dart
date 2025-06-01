import 'package:flutter/material.dart';
import 'package:medife/features/medication/MediEdit/component/mediedit_field.dart';

/// “약 이름 입력” 텍스트필드를 독립 위젯으로 분리

class NameField extends StatelessWidget {
  final TextEditingController controller;

  const NameField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EditField(
      label: '약 이름',
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: '약 이름을 입력하세요',
        ),
      ),
    );
  }
}

/// (주의) EditField는 아래 예시처럼 “레이블 + 내부 콘텐츠”를 묶어 주는 재사용 위젯으로
/// 따로 만들어 두면 좋습니다.
/// 예시:
///
/// class EditField extends StatelessWidget {
///   final String label;
///   final Widget child;
///   const EditField({Key? key, required this.label, required this.child})
///       : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       crossAxisAlignment: CrossAxisAlignment.start,
///       children: [
///         Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
///         const SizedBox(height: 8),
///         child,
///       ],
///     );
///   }
/// }
