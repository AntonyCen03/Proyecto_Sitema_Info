import 'package:flutter/material.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  // Singleton para acceso global fácil
  static final ThemeNotifier _instance = ThemeNotifier._internal();

  factory ThemeNotifier() => _instance;

  ThemeNotifier._internal() : super(ThemeMode.light);

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => value == ThemeMode.dark;
}

final themeNotifier = ThemeNotifier();
