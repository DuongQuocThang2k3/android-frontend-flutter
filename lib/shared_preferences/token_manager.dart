import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';

class TokenManager {
  static const String _tokenKey = 'jwt_token';
  static const String _sessionKey = 'session_data';
  static const String _passwordKey = 'user_password';
  static const String _otpKey = 'user_otp';
  static const String _otpTimeKey = 'user_otp_time';
  static const String _cartKey = 'shopping_cart';
  static const String _userIdKey = 'user_id';

  /// JWT token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Session JSON (username, roles,…)
  static Future<void> saveSession(String session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, session);
  }
  static Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }
  static Future<void> removeSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  static Future<void> clearSession() => removeSession();

  /// Password (optional)
  static Future<void> savePassword(String pw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, pw);
  }
  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }
  static Future<void> removePassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordKey);
  }

  /// OTP + timestamp
  static Future<void> saveOtp(String otp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_otpKey, otp);
    await prefs.setInt(_otpTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<String?> getOtp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_otpKey);
  }

  static Future<int?> getOtpTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_otpTimeKey);
  }

  static Future<void> removeOtp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_otpKey);
    await prefs.remove(_otpTimeKey);
  }

  /// Xóa hết
  static Future<void> clearAll() async {
    await removeToken();
    await removeSession();
    await removePassword();
    await removeOtp();
    await clearCart();
  }

  /// Decode JWT
  static Future<Map<String, dynamic>> getDecodedToken() async {
    final token = await getToken();
    if (token == null) return {};
    try {
      return JwtDecoder.decode(token);
    } catch (_) {
      return {};
    }
  }

  /// Username trong session JSON
  static Future<String?> getUsername() async {
    final s = await getSession();
    if (s == null) return null;
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return m['username'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Lấy userId: thử từ token.claims.sub/nameid, fallback session.userId
  static Future<String?> getUserId() async {
    // từ token
    final token = await getToken();
    if (token != null) {
      try {
        final d = JwtDecoder.decode(token);
        final id = (d['sub'] as String?) ?? (d['nameid'] as String?);
        if (id != null && id.isNotEmpty) return id;
      } catch (_) {}
    }
    // từ session
    final s = await getSession();
    if (s != null) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return m['userId'] as String?;
      } catch (_) {}
    }
    // fallback stored key
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
  }

  /// Lấy số điện thoại user từ token.claims.phoneNumber hoặc session JSON
  static Future<String?> getUserPhone() async {
    // Thử từ token
    final token = await getToken();
    if (token != null) {
      try {
        final d = JwtDecoder.decode(token);
        final phone = d['phoneNumber'] as String?;
        if (phone != null && phone.isNotEmpty) return phone;
      } catch (_) {}
    }
    // Fallback session JSON
    final s = await getSession();
    if (s != null) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return m['phone'] as String?;
      } catch (_) {}
    }
    return null;
  }

  /// Lấy địa chỉ user từ token.claims.address hoặc session JSON
  static Future<String?> getUserAddress() async {
    // Thử từ token
    final token = await getToken();
    if (token != null) {
      try {
        final d = JwtDecoder.decode(token);
        final addr = d['address'] as String?;
        if (addr != null && addr.isNotEmpty) return addr;
      } catch (_) {}
    }
    // Fallback session JSON
    final s = await getSession();
    if (s != null) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return m['address'] as String?;
      } catch (_) {}
    }
    return null;
  }

  /// Giỏ hàng lưu dưới dạng JSON string list
  static Future<void> saveCart(List<CartItem> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = cart.map((c) => c.toJson()).toList();
    await prefs.setString(_cartKey, jsonEncode(jsonList));
  }

  static Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_cartKey);
    if (str == null) return [];
    try {
      final arr = jsonDecode(str) as List;
      return arr.map((e) => CartItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  /// Caching instance của SharedPreferences trong TokenManager
  static SharedPreferences? _instance;

  /// Hàm static getInstance() trả về một instance của SharedPreferences.
  static Future<SharedPreferences> getInstance() async {
    if (_instance == null) {
      _instance = await SharedPreferences.getInstance();
    }
    return _instance!;
  }
}
