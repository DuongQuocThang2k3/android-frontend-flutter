import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'jwt_token';
  static const String _sessionKey = 'session_data';
  static const String _passwordKey = 'user_password';

  /// Lưu JWT token vào SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Lấy JWT token từ SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Xóa JWT token khỏi SharedPreferences
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Lưu session JSON (ví dụ chứa username, user_info, role, ...) vào SharedPreferences
  static Future<void> saveSession(String session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, session);
  }

  /// Lấy session JSON từ SharedPreferences
  static Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  /// Xóa session khỏi SharedPreferences
  static Future<void> removeSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  /// Alias cho removeSession()
  static Future<void> clearSession() async {
    await removeSession();
  }

  /// Lưu mật khẩu (nếu cần) vào SharedPreferences
  static Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, password);
  }

  /// Lấy mật khẩu từ SharedPreferences
  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }

  /// Xóa mật khẩu khỏi SharedPreferences
  static Future<void> removePassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordKey);
  }

  /// Xóa tất cả: token, session và password
  static Future<void> clearAll() async {
    await removeToken();
    await removeSession();
    await removePassword();
  }

  /// Giải mã JWT token lưu trong SharedPreferences
  static Future<Map<String, dynamic>> getDecodedToken() async {
    final token = await getToken();
    if (token == null) return {};
    try {
      return JwtDecoder.decode(token);
    } catch (_) {
      return {};
    }
  }

  /// Lấy username từ session JSON (key: "username")
  static Future<String?> getUsername() async {
    final session = await getSession();
    if (session == null) return null;
    try {
      final data = jsonDecode(session) as Map<String, dynamic>;
      return data['username'] as String?;
    } catch (_) {
      return null;
    }
  }
}
