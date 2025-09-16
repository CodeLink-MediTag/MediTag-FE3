import 'package:flutter/material.dart';

class SignupAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SignupAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appBarTheme = Theme.of(context).appBarTheme;
    final cs = Theme.of(context).colorScheme;

    final bg = appBarTheme.backgroundColor ?? cs.primary;
    final fg = appBarTheme.foregroundColor ?? cs.onPrimary;
    final titleStyle = appBarTheme.titleTextStyle ??
        Theme.of(context).textTheme.titleLarge?.copyWith(color: fg, fontWeight: FontWeight.w600);

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: fg),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: bg,
      elevation: appBarTheme.elevation ?? 0,
      centerTitle: appBarTheme.centerTitle ?? true,
      title: Text('', style: titleStyle),
    );
  }
}
