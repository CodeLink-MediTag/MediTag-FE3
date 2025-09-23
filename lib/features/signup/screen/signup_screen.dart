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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const SignupAppBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
