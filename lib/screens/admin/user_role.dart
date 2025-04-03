import 'package:flutter/material.dart';

class UserRolePage extends StatefulWidget {
  const UserRolePage({super.key});

  @override
  _UserRolePageState createState() => _UserRolePageState();
}

class _UserRolePageState extends State<UserRolePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _userRoles = ['Admin']; // Giới hạn chỉ có 'Admin' role
  final List<String> _availableRoles = ['User']; // Giới hạn chỉ có 'User' role
  String _searchUser = '';

  // Hàm tìm kiếm người dùng
  void _searchUserByName() {
    setState(() {
      _searchUser = _searchController.text;
    });
  }

  // Gán role cho người dùng
  void _assignRole(String role) {
    setState(() {
      _userRoles.add(role);
      _availableRoles.remove(role);
    });
  }

  // Xóa role của người dùng
  void _removeRole(String role) {
    setState(() {
      _userRoles.remove(role);
      _availableRoles.add(role);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý quyền người dùng'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tìm kiếm người dùng
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm User',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUserByName,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Danh sách role người dùng đang thuộc về
            const Text('Role user thuộc về:'),
            SizedBox(
              height: 150,
              child: ListView(
                children: _userRoles.map((role) {
                  return ListTile(
                    title: Text(role),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _removeRole(role),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Danh sách role người dùng không thuộc về
            const Text('Role user không thuộc về:'),
            SizedBox(
              height: 150,
              child: ListView(
                children: _availableRoles.map((role) {
                  return ListTile(
                    title: Text(role),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _assignRole(role),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
