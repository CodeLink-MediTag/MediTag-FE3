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

    // ListView에 키보드 높이만큼 패딩을 추가해서 overflow 경고 제거
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const SignupAppBar(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
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
