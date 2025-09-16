// lib/features/medication/MediMain/component/medimain_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medife/features/calendar/screen/calendar_screen.dart';

class MediMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback? onCalendar; // optional - you can pass null if not used

  const MediMainAppBar({
    Key? key,
    required this.onBack,
    this.onCalendar,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final colorScheme = theme.colorScheme;

    // background: appBarTheme.backgroundColor -> colorScheme.primary
    final Color bg = appBarTheme.backgroundColor ?? colorScheme.primary;
    // foreground: appBarTheme.foregroundColor -> colorScheme.onPrimary
    final Color fg = appBarTheme.foregroundColor ?? colorScheme.onPrimary;

    // decide overlay (status bar icons) by bg brightness, unless appBarTheme.systemOverlayStyle provided
    final SystemUiOverlayStyle overlay = appBarTheme.systemOverlayStyle ??
        (ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
            ? SystemUiOverlayStyle.light.copyWith(statusBarColor: bg)
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: bg));

    final TextStyle titleStyle = (appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge ?? const TextStyle())
        .copyWith(color: fg, fontWeight: FontWeight.bold, fontSize: 20);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: appBarTheme.elevation ?? 0,
        centerTitle: appBarTheme.centerTitle ?? true,
        title: Text(
          '복약 알림창',
          style: titleStyle.copyWith(fontFamily: 'SEBANG'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: fg),
          tooltip: '뒤로가기',
          onPressed: onBack,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: fg),
            tooltip: '달력 보기',
            onPressed: () {
              if (onCalendar != null) {
                onCalendar!();
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarScreen()),
              );
            },
          ),
        ],
        systemOverlayStyle: overlay, // safe-guard
      ),
    );
  }
}
