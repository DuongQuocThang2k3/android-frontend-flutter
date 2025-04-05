import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'jwt_token';
  static const String _sessionKey = 'session_data';
  static const String _passwordKey = 'user_password';

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

  // Hàm nhận và giải mã token từ SharedPreferences
  static Future<Map<String, dynamic>> getDecodedToken() async {
    String? token = await getToken();
    if (token == null) {
      return {};
    }
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      // Trường hợp giải mã thất bại
      return {};
    }
  }

  // Lưu mật khẩu vào SharedPreferences
  static Future<void> savePassword(String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, password);
  }

  // Lấy mật khẩu từ SharedPreferences
  static Future<String?> getPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }

  // Xóa mật khẩu khỏi SharedPreferences
  static Future<void> removePassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordKey);
  }
}
