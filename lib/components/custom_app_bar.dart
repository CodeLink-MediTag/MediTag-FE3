import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final bool showHome;
  final List<Widget>? actions;
  final double height;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBack,
    this.onHome,
    this.showHome = true,
    this.actions,
    this.height = kToolbarHeight + 16,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  Widget? _buildLeading(BuildContext context, Color? fgColor) {
    if (onBack != null) {
      return IconButton(
        icon: Icon(Icons.arrow_back, color: fgColor),
        onPressed: onBack,
        tooltip: '뒤로가기',
      );
    }
    if (Navigator.canPop(context)) {
      return IconButton(
        icon: Icon(Icons.arrow_back, color: fgColor),
        onPressed: () => Navigator.of(context).maybePop(),
        tooltip: '뒤로가기',
      );
    }
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.hasDrawer) {
      return IconButton(
        icon: Icon(Icons.menu, color: fgColor),
        onPressed: () => scaffold.openDrawer(),
        tooltip: '메뉴',
      );
    }
    return const SizedBox(width: kToolbarHeight);
  }

  void _defaultHomeAction(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/landing', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final appBarTheme = Theme.of(context).appBarTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final bg = appBarTheme.backgroundColor ?? colorScheme.primary;
    final fg = appBarTheme.foregroundColor ?? colorScheme.onPrimary;
    final overlay = appBarTheme.systemOverlayStyle;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay ?? SystemUiOverlayStyle.dark,
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bg,
        foregroundColor: fg,
        centerTitle: appBarTheme.centerTitle ?? true,
        elevation: appBarTheme.elevation,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'SEBANG', // 폰트명 고정
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: fg,
          ),
        ),
        leading: _buildLeading(context, fg),
        actions: [
          if (showHome)
            IconButton(
              icon: Icon(Icons.home, color: fg),
              onPressed: () {
                if (onHome != null) {
                  onHome!();
                } else {
                  _defaultHomeAction(context);
                }
              },
              tooltip: '홈으로',
            ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
