import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';

import '../shared_preferences/token_manager.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final bool emailConfirmed;
  final bool twoFactorEnabled;
  final bool lockoutEnabled;
  final int accessFailedCount;
  final String token;

  // Lưu trữ người dùng hiện tại
  static UserModel? currentUser;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.emailConfirmed,
    required this.twoFactorEnabled,
    required this.lockoutEnabled,
    required this.accessFailedCount,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Lấy token từ JSON
    final tokenValue = json['token'] as String? ?? '';
    // Giải mã token nếu có để lấy thêm các thông tin (nếu chưa có trong JSON)
    Map<String, dynamic> tokenData = {};
    if (tokenValue.isNotEmpty) {
      try {
        tokenData = JwtDecoder.decode(tokenValue);
      } catch (_) {}
    }
    return UserModel(
      token: tokenValue,
      id: json['id'] as String? ?? json['Id'] as String? ?? '',
      username: json['username'] as String? ??
          json['userName'] as String? ??
          json['UserName'] as String? ??
          tokenData['username'] as String? ??
          '',
      email: json['email'] as String? ??
          json['Email'] as String? ??
          tokenData['email'] as String? ??
          '',
      fullName: json['fullName'] as String? ??
          json['FullName'] as String? ??
          '', // Giả sử fullName không có trong token
      role: json['role'] as String? ??
          json['Role'] as String? ??
          tokenData['role'] as String? ??
          'User',
      emailConfirmed: json['emailConfirmed'] as bool? ??
          json['EmailConfirmed'] as bool? ??
          false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      lockoutEnabled: json['lockoutEnabled'] as bool? ?? false,
      accessFailedCount: json['accessFailedCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': username,
      'email': email,
      'fullName': fullName,
      'role': role,
      'emailConfirmed': emailConfirmed,
      'twoFactorEnabled': twoFactorEnabled,
      'lockoutEnabled': lockoutEnabled,
      'accessFailedCount': accessFailedCount,
      'token': token,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? role,
    bool? emailConfirmed,
    bool? twoFactorEnabled,
    bool? lockoutEnabled,
    int? accessFailedCount,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      lockoutEnabled: lockoutEnabled ?? this.lockoutEnabled,
      accessFailedCount: accessFailedCount ?? this.accessFailedCount,
      token: token ?? this.token,
    );
  }

  bool get isAdmin => role.toLowerCase() == 'admin';

  /// Lấy số điện thoại: ưu tiên token.claims.phone_number, fallback session JSON
  Future<String?> get phoneNumber async {
    try {
      final claims = JwtDecoder.decode(token);
      final phone = claims['phone_number'] as String?;
      if (phone != null && phone.isNotEmpty) return phone;
    } catch (_) {}
    final session = await TokenManager.getSession();
    if (session != null) {
      try {
        final m = jsonDecode(session) as Map<String, dynamic>;
        return m['phoneNumber'] as String?;
      } catch (_) {}
    }
    return null;
  }

  /// Lấy địa chỉ: ưu tiên token.claims.address, fallback session JSON
  Future<String?> get address async {
    try {
      final claims = JwtDecoder.decode(token);
      final addr = claims['address'] as String?;
      if (addr != null && addr.isNotEmpty) return addr;
    } catch (_) {}
    final session = await TokenManager.getSession();
    if (session != null) {
      try {
        final m = jsonDecode(session) as Map<String, dynamic>;
        return m['address'] as String?;
      } catch (_) {}
    }
    return null;
  }

  /// Lấy lastLogin: ưu tiên token.claims.last_login, fallback session JSON
  Future<String?> get lastLogin async {
    try {
      final claims = JwtDecoder.decode(token);
      final ll = claims['last_login'] as String?;
      if (ll != null && ll.isNotEmpty) return ll;
    } catch (_) {}
    final session = await TokenManager.getSession();
    if (session != null) {
      try {
        final m = jsonDecode(session) as Map<String, dynamic>;
        return m['lastLogin'] as String?;
      } catch (_) {}
    }
    return null;
  }

  /// Gán người dùng hiện tại, lưu vào cache: token và session
  static void setCurrentUser(UserModel user) {
    currentUser = user;
    TokenManager.saveToken(user.token);
    // Lưu thông tin user (bao gồm username, email, role, ...) dưới dạng session JSON
    TokenManager.saveSession(jsonEncode(user.toJson()));
  }

  static void resetCurrentUser() {
    currentUser = null;
    TokenManager.clearAll();
  }
}
