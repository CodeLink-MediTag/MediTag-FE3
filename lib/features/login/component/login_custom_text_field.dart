import 'package:flutter/material.dart';

class LoginCustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final TextEditingController? controller;
  final IconData? icon;
  final Widget? suffixIcon;

  const LoginCustomTextField({
    super.key,
    required this.hintText,
    required this.validator,
    required this.onSaved,
    this.obscureText = false,
    this.controller,
    this.icon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onSaved: onSaved,
      validator: validator,
      obscureText: obscureText,
      obscuringCharacter: '*',
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
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}