import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/config_url.dart';
import 'admin_screen.dart';

class AdminRolePage extends StatefulWidget {
  @override
  _AdminRolePageState createState() => _AdminRolePageState();
}

class _AdminRolePageState extends State<AdminRolePage> {
  final TextEditingController _roleController = TextEditingController();
  Map<String, bool> _permissions = {
    'view': false,
    'edit': false,
    'delete': false,
  };
  bool _selectAll = false;
  String _selectedRole = 'Admin';

  // Khi nhấn vào "All" checkbox, đánh dấu tất cả các quyền
  void _toggleAllPermissions(bool? value) {
    setState(() {
      _selectAll = value!;
      _permissions['view'] = _selectAll;
      _permissions['edit'] = _selectAll;
      _permissions['delete'] = _selectAll;
    });
  }

  Future<void> _addClaimToRole() async {
    // Code thêm claim vào role...
  }

  Future<void> _removeClaimFromRole() async {
    // Code xóa claim khỏi role...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý quyền')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown cho role
            Row(
              children: [
                Text('Role: '),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  items: <String>['Admin', 'User']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Product'),
                Spacer(),
                Checkbox(
                  value: _selectAll,
                  onChanged: _toggleAllPermissions,
                ),
                Text('All'),
                Checkbox(
                  value: _permissions['view'],
                  onChanged: (bool? value) {
                    setState(() {
                      _permissions['view'] = value!;
                    });
                  },
                ),
                Text('View'),
                Checkbox(
                  value: _permissions['edit'],
                  onChanged: (bool? value) {
                    setState(() {
                      _permissions['edit'] = value!;
                    });
                  },
                ),
                Text('Edit'),
                Checkbox(
                  value: _permissions['delete'],
                  onChanged: (bool? value) {
                    setState(() {
                      _permissions['delete'] = value!;
                    });
                  },
                ),
                Text('Delete'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addClaimToRole,
              child: Text('Thêm quyền'),
            ),
            ElevatedButton(
              onPressed: _removeClaimFromRole,
              child: Text('Xóa quyền'),
            ),
            // Nút để dẫn đường đến admin_screen.dart
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminScreen()),
                );
              },
              child: Text('Đi đến Admin Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
