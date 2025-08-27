import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onHome; // 전달하면 그 콜백을 사용
  final bool showHome; // 기본적으로 true -> 홈 버튼 보임
  final List<Widget>? actions;
  final double height;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBack,
    this.onHome,
    this.showHome = true, // 기본값 true
    this.actions,
    this.height = kToolbarHeight + 16,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  Widget? _buildLeading(BuildContext context, Color? fgColor) {
    // 1) 명시적 onBack 사용
    if (onBack != null) {
      return IconButton(
        icon: Icon(Icons.arrow_back, color: fgColor),
        onPressed: onBack,
        tooltip: '뒤로가기',
      );
    }

    // 2) 네비게이터에 뒤로갈 수 있으면 pop 버튼
    if (Navigator.canPop(context)) {
      return IconButton(
        icon: Icon(Icons.arrow_back, color: fgColor),
        onPressed: () => Navigator.of(context).maybePop(),
        tooltip: '뒤로가기',
      );
    }

    // 3) Drawer가 있으면 햄버거 버튼
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.hasDrawer) {
      return IconButton(
        icon: Icon(Icons.menu, color: fgColor),
        onPressed: () => scaffold.openDrawer(),
        tooltip: '메뉴',
      );
    }

    // 4) 아무 것도 없으면 자리 유지
    return const SizedBox(width: kToolbarHeight);
  }

  void _defaultHomeAction(BuildContext context) {
    // 기본 홈 동작: Landing으로 가며 모든 스택 제거
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
          style: appBarTheme.titleTextStyle ??
              TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: fg),
        ),
        leading: _buildLeading(context, fg),
        actions: [
          // showHome이 true면 홈 버튼 표시 (onHome 있으면 그 콜백, 없으면 기본 동작)
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

          // 기존 actions 전달
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
