import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignupTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final TextEditingController? controller;


  const SignupTextField({
    Key? key,
    required this.label,
    required this.validator,
    required this.onSaved,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onSaved: onSaved,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}