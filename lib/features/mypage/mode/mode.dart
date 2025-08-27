// lib/features/mypage/mode/mode.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 내에서 사용할 모드(시스템 유지 포함)
enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeProvider extends ChangeNotifier {
  static const _prefsKey = 'app_theme_mode';

  AppThemeMode _mode = AppThemeMode.system;
  bool _initialized = false;

  ThemeProvider() {
    _loadFromPrefs();
  }

  bool get initialized => _initialized;

  AppThemeMode get mode => _mode;

  /// Flutter의 ThemeMode로 변환 (MaterialApp에 전달)
  ThemeMode get themeMode {
    switch (_mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }

  /// UI/다이얼로그에서 호출 -> 내부적으로 저장하고 notify
  Future<void> setMode(AppThemeMode newMode) async {
    if (_mode == newMode) return;
    _mode = newMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _mode.name);
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_prefsKey);
      if (s != null) {
        _mode = AppThemeMode.values.firstWhere((e) => e.name == s, orElse: () => AppThemeMode.system);
      } else {
        _mode = AppThemeMode.system;
      }
    } catch (_) {
      _mode = AppThemeMode.system;
    }
    _initialized = true;
    notifyListeners();
  }
}
