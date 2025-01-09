import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_cherry_pet_shop/models/user_model.dart';
import 'Auth/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isLoggedIn = false; // Trạng thái đăng nhập
  UserModel? userModel; // Model lưu thông tin người dùng

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Kiểm tra trạng thái đăng nhập
  void _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('user_info');

    if (userData != null) {
      setState(() {
        isLoggedIn = true;
        userModel = UserModel.fromJson(json.decode(userData));
      });
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      // Chưa đăng nhập
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Chuyển đến màn hình đăng nhập
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ).then((_) {
                _checkLoginStatus(); // Kiểm tra lại trạng thái sau khi đăng nhập
              });
            },
            child: const Text('Đăng nhập'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
          ),
        ),
      );
    }

    // Đã đăng nhập và có dữ liệu user
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Khung màu xanh thay cho hình đại diện
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),

            // Hiển thị thông tin username
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.blueAccent),
              title: const Text('Tên đăng nhập'),
              subtitle: Text(userModel?.username ?? 'Không có thông tin'),
            ),

            // Hiển thị thông tin role
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.blueAccent),
              title: const Text('Vai trò'),
              subtitle: Text(userModel?.role ?? 'Không xác định'),
            ),
          ],
        ),
      ),
    );
  }
}
