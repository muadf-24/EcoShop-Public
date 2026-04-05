import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeModeKey = 'theme_mode';
  final SharedPreferences _prefs;

  final ValueNotifier<ThemeMode> themeModeNotifier;

  ThemeService(this._prefs)
      : themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final String? savedThemeMode = _prefs.getString(_themeModeKey);
    if (savedThemeMode != null) {
      themeModeNotifier.value = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
    themeModeNotifier.value = mode;
  }

  ThemeMode get currentThemeMode => themeModeNotifier.value;

  bool get isDarkMode => currentThemeMode == ThemeMode.dark;
  bool get isLightMode => currentThemeMode == ThemeMode.light;
  bool get isSystemMode => currentThemeMode == ThemeMode.system;

  Future<void> toggleTheme() async {
    final newMode = currentThemeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
}