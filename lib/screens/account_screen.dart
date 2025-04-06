import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/models/user_model.dart';
import 'package:the_cherry_pet_shop/shared_preferences/token_manager.dart';

import 'Auth/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isLoggedIn = false;
  UserModel? userModel;
  String? _username;

  // Bảng màu sang trọng
  final Color primaryColor = const Color(0xFF6A1B9A);
  final Color secondaryColor = const Color(0xFFE1BEE7);
  final Color accentColor = const Color(0xFF4A148C);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color textColor = const Color(0xFF212121);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load thông tin user từ TokenManager
  Future<void> _loadUserData() async {
    final String? session = (await TokenManager.getSession()) as String?;
    if (session != null) {
      try {
        final data = json.decode(session) as Map<String, dynamic>;
        setState(() {
          isLoggedIn = true;
          _username = data['username'] as String?;
          userModel = UserModel.fromJson(data['user_info']);
        });
      } catch (e) {
        // nếu parse lỗi thì coi như chưa đăng nhập
        setState(() {
          isLoggedIn = false;
          _username = null;
          userModel = null;
        });
        print("Lỗi parse session: $e");
      }
    } else {
      setState(() {
        isLoggedIn = false;
        _username = null;
        userModel = null;
      });
    }
  }

  /// Đăng xuất: xóa hết data và chuyển về LoginScreen
  Future<void> _logout() async {
    // Xóa token, session và password
    await TokenManager.clearAll();

    // Cập nhật state
    setState(() {
      isLoggedIn = false;
      _username = null;
      userModel = null;
    });

    // Thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đăng xuất thành công'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Điều hướng về LoginScreen, xoá hết stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Tài khoản',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoggedIn ? _buildLoggedInView() : _buildLoginView(),
    );
  }

  Widget _buildLoginView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, secondaryColor.withOpacity(0.3)],
        ),
      ),
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          elevation: 10,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets,
                    size: 70,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Chào mừng đến với Cherry Pet Shop',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Đăng nhập để quản lý tài khoản và đặt hàng dễ dàng hơn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ).then((_) => _loadUserData());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: primaryColor.withOpacity(0.5),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedInView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, secondaryColor.withOpacity(0.3)],
        ),
      ),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 10,
          shadowColor: primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar with decoration
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryColor, accentColor],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white70,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Thông tin tài khoản
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.account_circle,
                        label: 'Thông tin tài khoản',
                        value: _username ?? 'Không có thông tin',
                      ),
                      const Divider(height: 25),
                      _buildInfoRow(
                        icon: Icons.admin_panel_settings,
                        label: 'Quyền hạn',
                        value: userModel?.role ?? 'Không xác định',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Logout button
                ElevatedButton.icon(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: Colors.red.withOpacity(0.3),
                  ),
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
