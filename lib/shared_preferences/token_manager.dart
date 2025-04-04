import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'jwt_token';
  static const String _sessionKey = 'session_data';

  // Lưu token vào SharedPreferences
  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Lấy token từ SharedPreferences
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Xóa token khỏi SharedPreferences
  static Future<void> removeToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Lưu session vào SharedPreferences
  static Future<void> saveSession(String session) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, session);
  }

  // Lấy session từ SharedPreferences
  static Future<String?> getSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  // Xóa session khỏi SharedPreferences
  static Future<void> removeSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
