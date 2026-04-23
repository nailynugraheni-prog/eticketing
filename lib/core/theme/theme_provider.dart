import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final stored = await LocalStorageService.getRole(); // sementara, nanti ganti key theme
    _isDarkMode = stored == 'dark';
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    await LocalStorageService.saveRole(value ? 'dark' : 'light'); // nanti ganti key theme
    notifyListeners();
  }
}