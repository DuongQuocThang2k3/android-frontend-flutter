import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

import 'login_screen.dart'; // Import màn hình đăng nhập

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  // Hàm xử lý đăng xuất và xóa token
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // Xóa token khỏi SharedPreferences

    // Điều hướng về màn hình đăng nhập sau khi xóa token
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // Xóa tất cả các màn hình trước đó khỏi ngăn xếp
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng xuất'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc
          crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều ngang
          children: [
            const Text(
              'Bạn muốn đăng xuất không?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context), // Gọi hàm logout khi nhấn nút
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }

}
