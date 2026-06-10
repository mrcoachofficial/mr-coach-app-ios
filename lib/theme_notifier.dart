import 'package:flutter/material.dart';
import 'package:mrcoach/theme_notifier.dart';


class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); 
  }

  void toggle() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();