import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/screens/video_screen.dart';
import 'Auth/logout_screen.dart';
import 'home_screen.dart';
import 'account_screen.dart';
import 'market_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Simplified screens list without video assets
  final List<Widget> _screens = [
    const HomeScreen(),
    const VideoListScreen(), // Using YouTube videos instead of local assets
    const AccountScreen(),
    const MarketScreen(),
  ];

  Color _getIconColor(int index) {
    return _currentIndex == index ? Colors.blueAccent : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facebook Fake'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Điều hướng đến màn hình Logout khi nhấn vào nút "Đăng xuất"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogoutScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(  // Using IndexedStack to preserve state
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
