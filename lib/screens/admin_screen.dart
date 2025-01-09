import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';


import 'Auth/login_screen.dart'; // Import LoginScreen

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Xóa thông tin người dùng từ SharedPreferences (nếu có)
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwt_token');  // Xóa token để logout

              // Chuyển hướng về màn hình Login sau khi đăng xuất
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome, Admin!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
