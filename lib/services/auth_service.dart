import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'sheets_service.dart';

class AuthService {
  static const _key = 'current_user';

  static Future<Map<String, dynamic>?> login(
      String phone, String password) async {
    final user = await SheetsService.validateLogin(phone, password);
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(user));
    }
    return user;
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return null;
    return jsonDecode(data);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}