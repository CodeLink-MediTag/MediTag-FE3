// login_custom_text_field.dart
import 'package:flutter/material.dart';

class LoginCustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final TextEditingController? controller;
  final IconData? icon;

  const LoginCustomTextField({
    super.key,
    required this.hintText,
    required this.validator,
    required this.onSaved,
    this.obscureText = false,
    this.controller,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onSaved: onSaved,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF4F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}
