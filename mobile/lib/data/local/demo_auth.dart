import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DemoAuth {
  static const _emailKey = 'local_demo_email';
  static const _nameKey = 'local_demo_name';
  static const _passwordKey = 'local_demo_password_hash';

  static String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

  static Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_emailKey);
    final savedHash = prefs.getString(_passwordKey);
    if (savedEmail == null || savedHash == null) return false;
    return savedEmail.toLowerCase() == email.trim().toLowerCase() && savedHash == _hash(password);
  }

  static Future<void> register(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name.trim());
    await prefs.setString(_emailKey, email.trim().toLowerCase());
    await prefs.setString(_passwordKey, _hash(password));
  }

  static Future<String> name() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'گەشتیار';
  }
}
