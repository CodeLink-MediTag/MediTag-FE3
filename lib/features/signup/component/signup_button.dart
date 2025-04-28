import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignupButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SignupButton({
    Key? key,
    required this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '회원가입',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );

  }
}