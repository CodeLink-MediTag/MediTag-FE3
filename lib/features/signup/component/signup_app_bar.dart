
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignupAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SignupAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
