import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginCustomTextField extends StatelessWidget{
  final String hintText;
  final bool obscureText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final TextEditingController? controller;

  const LoginCustomTextField({
    super.key,
    required this.hintText,
    required this.validator,
    required this.onSaved,
    this.obscureText = false,
    this.controller
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
        border: OutlineInputBorder(),
      ),
    );
  }
}