import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextSizeProvider extends ChangeNotifier {
  double _textSize = 14.0;
  double get textSize => _textSize;

  TextSizeProvider() {
    _loadTextSize();
  }

  Future<void> _loadTextSize() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedSize = prefs.getDouble('textSize') ?? 14.0;
    _textSize = (loadedSize > 0) ? loadedSize : 14.0; // 0 이하 방지
    notifyListeners();
  }

  Future<void> setTextSize(double size) async {
    _textSize = (size > 0) ? size : 14.0; // 0 이하 방지
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', _textSize);
  }
}
