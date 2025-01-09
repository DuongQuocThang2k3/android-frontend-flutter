import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_cherry_pet_shop/models/user_model.dart';
import 'package:the_cherry_pet_shop/screens/video_screen.dart';
import 'package:the_cherry_pet_shop/screens/map_screen.dart'; // Import màn hình MapHere
import 'home_screen.dart';
import 'account_screen.dart';
import 'admin_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool isLoggedIn = false; // Trạng thái đăng nhập
  bool isAdmin = false; // Trạng thái quyền Admin
  UserModel? userModel; // Dữ liệu người dùng

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // Kiểm tra vai trò người dùng
  }

  Future<void> _checkUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('user_info');

    if (userData != null) {
      setState(() {
        isLoggedIn = true;
        userModel = UserModel.fromJson(json.decode(userData));
        isAdmin = userModel?.role == 'Admin'; // Kiểm tra vai trò Admin
      });
    } else {
      setState(() {
        isLoggedIn = false;
        isAdmin = false;
      });
    }

    // Cấu hình danh sách màn hình
    setState(() {
      _screens = [
        const HomeScreen(),
        const VideoListScreen(),
        MapScreen(), // Thêm màn hình MapHere
        if (isAdmin) const AdminScreen(), // Chỉ thêm AdminScreen nếu là Admin
        const AccountScreen(),
      ];
    });
  }

  Color _getIconColor(int index) {
    return _currentIndex == index ? Colors.blueAccent : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Chặn truy cập màn hình Admin nếu không phải Admin
            if (index == 4 && !isAdmin) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bạn không có quyền truy cập màn hình Admin!')),
              );
              return;
            }
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: _getIconColor(0)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library, color: _getIconColor(1)),
              label: 'Video',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map, color: _getIconColor(3)),
              label: 'MapHere',
            ),
            if (isAdmin) // Chỉ hiển thị Admin nếu là Admin
              BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings, color: _getIconColor(4)),
                label: 'Admin',
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle, color: _getIconColor(5)),
              label: 'Account',
            ),
          ],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
        ),
      ),
    );
  }
}