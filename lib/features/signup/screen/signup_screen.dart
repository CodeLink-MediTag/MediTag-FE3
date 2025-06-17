import 'package:flutter/material.dart';
import 'package:medife/features/signup/component/signup_fields.dart';
import 'package:medife/main.dart';

import '../component/sginup_title.dart';
import '../component/signup_app_bar.dart';
import '../component/signup_button.dart';
import '../component/signup_text_field.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SignupAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SignupTitle(),
            const SizedBox(height: 24),
            SignupFields(),
          ],
        ),
      ),
    );
  }
}
