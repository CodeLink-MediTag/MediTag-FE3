import 'package:flutter/material.dart';

class SignupTextField extends StatefulWidget {
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
  State<SignupTextField> createState() => _SignupTextFieldState();
}

class _SignupTextFieldState extends State<SignupTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          onSaved: widget.onSaved,
          validator: widget.validator,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          obscuringCharacter: '*',
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintText: widget.label,
            hintStyle: const TextStyle(color: Colors.grey),
            // 👇 비밀번호 필드일 때만 눈 아이콘 추가
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscure = !_obscure;
                });
              },
            )
                : null,
          ),
        ),
      ],
    );
  }
}