// login_custom_button.dart
import 'package:flutter/material.dart';

class LoginCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final double? height;

  const LoginCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bg = backgroundColor ?? cs.primary;
    final fg = textColor ?? cs.onPrimary;
    final ts = textStyle ??
        theme.textTheme.titleMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        );

    return SizedBox(
      width: double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size.fromHeight(50),
          textStyle: ts,
        ),
        child: Text(text),
      ),
    );
  }
}
