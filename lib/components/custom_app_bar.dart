import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final bool showHome;
  final List<Widget>? actions;
  final double height; // 높이 옵션 추가

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBack,
    this.onHome,
    this.showHome = true,
    this.actions,
    this.height = kToolbarHeight + 16, // 기본 높이
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height); // height 사용

  Widget? _buildLeading(BuildContext context, Color fgColor) {
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

    final Color bg = appBarTheme.backgroundColor ?? colorScheme.primary;
    final Color fg = appBarTheme.foregroundColor ?? colorScheme.onPrimary;

    final SystemUiOverlayStyle overlay = appBarTheme.systemOverlayStyle ??
        (ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
            ? SystemUiOverlayStyle.light.copyWith(statusBarColor: bg)
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: bg));

    final TextStyle titleStyle = (appBarTheme.titleTextStyle ?? Theme.of(context).textTheme.titleLarge!)
        .copyWith(color: fg, fontWeight: FontWeight.w600);

    final IconThemeData iconTheme = appBarTheme.iconTheme ?? IconThemeData(color: fg);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bg,
        foregroundColor: fg,
        centerTitle: appBarTheme.centerTitle ?? true,
        elevation: appBarTheme.elevation ?? 0,
        title: Text(
          title,
          style: titleStyle.copyWith(fontFamily: 'SEBANG'),
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
        iconTheme: iconTheme,
        systemOverlayStyle: overlay,
      ),
    );
  }
}
