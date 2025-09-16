// login_custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginCustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final TextEditingController? controller;
  final IconData? icon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;

  const LoginCustomTextField({
    super.key,
    required this.hintText,
    required this.validator,
    required this.onSaved,
    this.obscureText = false,
    this.controller,
    this.icon,
    this.suffixIcon,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    final cs = theme.colorScheme;

    return TextFormField(
      controller: controller,
      onSaved: onSaved,
      validator: validator,
      obscureText: obscureText,
      obscuringCharacter: '*',
      inputFormatters: inputFormatters,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: inputTheme.hintStyle ?? theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.6)),
        filled: true,
        fillColor: inputTheme.fillColor ?? (theme.brightness == Brightness.dark ? cs.surface : cs.surfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: icon != null ? Icon(icon, color: theme.iconTheme.color) : null,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}
