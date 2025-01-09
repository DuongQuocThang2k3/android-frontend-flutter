import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/screens/video_screen.dart';
import 'home_screen.dart';
import 'account_screen.dart';
import 'market_screen.dart';
import 'admin_screen.dart'; // Import màn hình AdminScreen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách màn hình
  final List<Widget> _screens = [
    const HomeScreen(),
    const VideoListScreen(),
    const AccountScreen(),
    const MarketScreen(),
    const AdminScreen(), // Thêm AdminScreen
  ];

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
              icon: Icon(Icons.account_circle, color: _getIconColor(2)),
              label: 'Account',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart, color: _getIconColor(3)),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings, color: _getIconColor(4)), // Icon Admin
              label: 'Admin', // Label Admin
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