import 'package:flutter/material.dart';
import 'package:medife/features/medication/MediEdit/component/mediedit_field.dart';

/// “복용 기간 (일)”을 입력하는 부분만 따로 분리

class DurationField extends StatelessWidget {
  final TextEditingController controller;

  const DurationField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EditField(
      label: '복용 기간 (일)',
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: '예: 7', // 사용자 가이드용 힌트
        ),
      ),
    );
  }
}
