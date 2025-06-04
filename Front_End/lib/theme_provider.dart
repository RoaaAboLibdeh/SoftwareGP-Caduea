import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Define your colors here
  Color get primaryColor =>
      _isDarkMode ? const Color(0xFFBB86FC) : const Color(0xFF998BCF);
  Color get secondaryColor =>
      _isDarkMode ? const Color(0xFF03DAC6) : const Color(0xFFB8A8E6);
  Color get backgroundColor =>
      _isDarkMode ? const Color(0xFF121212) : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get cardColor => _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  // Add more colors as needed

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }
}
