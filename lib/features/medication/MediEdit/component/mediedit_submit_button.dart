// lib/features/medication/MediEdit/component/mediedit_submit_button.dart
import 'package:flutter/material.dart';
import 'package:medife/components/custom_primary_button.dart';

/// 저장(등록/수정) 버튼 - 기존 시그니처(onPressed: required)를 유지
class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const SubmitButton({
    Key? key,
    required this.onPressed,
    this.label = '저장',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return CustomPrimaryButton(
      label: label,
      onPressed: onPressed,
      height: 48,
      borderRadius: 16,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: cs.primary,
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: cs.onPrimary,
      ),
    );
  }
}
