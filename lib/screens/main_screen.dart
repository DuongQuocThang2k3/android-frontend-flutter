import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/models/user_model.dart';
import 'package:the_cherry_pet_shop/screens/map_screen.dart';
import 'package:the_cherry_pet_shop/screens/video_screen.dart';
import 'package:the_cherry_pet_shop/shared_preferences/token_manager.dart';

import 'account_screen.dart';
import 'admin/admin_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool isLoggedIn = false;
  bool isAdmin = false;
  UserModel? userModel;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Khởi tạo ban đầu danh sách màn hình (không có màn hình Admin)
    _screens = [
      const HomeScreen(),
      const VideoListScreen(),
      MapScreen(),
      const AccountScreen(),
    ];
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final String? userData = await TokenManager.getSession();

    if (userData != null) {
      try {
        userModel = UserModel.fromJson(json.decode(userData));
        isAdmin = (userModel?.role == 'Admin');
      } catch (e) {
        print("Error decoding user data: $e");
        isAdmin = false;
      }
    } else {
      isAdmin = false;
    }

    // Cập nhật danh sách màn hình dựa trên quyền admin
    setState(() {
      _screens = [
        const HomeScreen(),
        const VideoListScreen(),
        MapScreen(),
        if (isAdmin) const AdminScreen(),
        const AccountScreen(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Xây dựng danh sách BottomNavigationBarItem theo quyền admin
    List<BottomNavigationBarItem> bottomNavItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home, color: primaryColor),
        label: 'Trang chủ',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.video_library_outlined),
        activeIcon: Icon(Icons.video_library, color: primaryColor),
        label: 'Video',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.map_outlined),
        activeIcon: Icon(Icons.map, color: primaryColor),
        label: 'Bản đồ',
      ),
      if (isAdmin)
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings, color: primaryColor),
          label: 'Quản trị',
        ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle_outlined),
        activeIcon: Icon(Icons.account_circle, color: primaryColor),
        label: 'Tài khoản',
      ),
    ];

    // Nếu không phải admin, loại bỏ mục "Quản trị"
    if (!isAdmin) {
      bottomNavItems =
          bottomNavItems.where((item) => item.label != 'Quản trị').toList();
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1.0),
          ),
          color: Colors.white,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Nếu màn hình được chọn là AdminScreen nhưng người dùng không có quyền, thông báo lỗi
            if (_screens[index] is AdminScreen && !isAdmin) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bạn không có quyền truy cập màn hình Admin!'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: bottomNavItems,
        ),
      ),
    );
  }
}
