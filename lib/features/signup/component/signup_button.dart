import 'package:flutter/material.dart';

class SignupButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final double? height;

  const SignupButton({
    Key? key,
    required this.onPressed,
    this.label = '회원가입',
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textStyle = theme.textTheme.titleMedium?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w600);

    return SizedBox(
      width: double.infinity,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textStyle,
        ),
        child: Text(label),
      ),
    );
  }
}
