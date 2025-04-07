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
    required token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'],
      id: json['id'] as String? ?? '',
      username: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? 'User',
      emailConfirmed: json['emailConfirmed'] as bool? ?? false,
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
    };
  }

  bool get isAdmin => role == 'Admin';

  get phoneNumber => null;

  get address => null;

  static void setCurrentUser(UserModel user) {
    currentUser = user;
  }

  static void resetCurrentUser() {
    currentUser = null;
  }
}
