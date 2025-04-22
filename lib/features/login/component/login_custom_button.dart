import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const LoginCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF547EE8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size(double.infinity, 50),

            textStyle: TextStyle(
                fontSize: 20
            ),
            foregroundColor: Colors.white
        ),
        onPressed: onPressed,
        child: Text(
          text,

        ),
      ),
    );
  }
}