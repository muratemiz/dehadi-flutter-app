import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TemaSaglayici extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _themeKey = 'isDarkMode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    try {
      final box = await Hive.openBox(_boxName);
      _isDarkMode = box.get(_themeKey, defaultValue: false);
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      debugPrint('[TemaSaglayici.init] HATA: $e');
    }
  }

  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      final box = await Hive.openBox(_boxName);
      await box.put(_themeKey, _isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('[TemaSaglayici.toggleTheme] HATA: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      _isDarkMode = mode == ThemeMode.dark;
      final box = await Hive.openBox(_boxName);
      await box.put(_themeKey, _isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('[TemaSaglayici.setThemeMode] HATA: $e');
    }
  }

  Future<void> useSystemTheme() async {
    try {
      _themeMode = ThemeMode.system;
      final box = await Hive.openBox(_boxName);
      await box.delete(_themeKey);
      notifyListeners();
    } catch (e) {
      debugPrint('[TemaSaglayici.useSystemTheme] HATA: $e');
    }
  }
}
