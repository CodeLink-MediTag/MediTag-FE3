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
    _textSize = prefs.getDouble('textSize') ?? 14.0;
    notifyListeners();
  }

  Future<void> setTextSize(double size) async {
    _textSize = size;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', size);
  }
}
