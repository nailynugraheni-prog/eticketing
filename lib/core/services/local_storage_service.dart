import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _tokenKey = 'token';
  static const String _roleKey = 'role';
  static const String _userIdKey = 'user_id';
  static const String _nameKey = 'name';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveRole(String role) async {
    final prefs = await _prefs;
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getRole() async {
    final prefs = await _prefs;
    return prefs.getString(_roleKey);
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }

  static Future<void> saveName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_nameKey, name);
  }

  static Future<String?> getName() async {
    final prefs = await _prefs;
    return prefs.getString(_nameKey);
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}