import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config_url.dart';
import '../../models/user_model.dart';
import 'admin_screen.dart';

class AdminRolePage extends StatefulWidget {
  const AdminRolePage({super.key});

  @override
  _AdminRolePageState createState() => _AdminRolePageState();
}

class _AdminRolePageState extends State<AdminRolePage> {
  Map<String, bool> _permissions = {};
  bool _selectAll = false;
  String _selectedRole = UserModel.currentUser?.role ?? 'Admin';
  bool _loading = false;
  List<String> _availableRoles = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableRoles();
    _fetchRoleClaims();
  }

  Future<void> _fetchAvailableRoles() async {
    // Giả định danh sách role có sẵn
    setState(() {
      _availableRoles = ['Admin', 'User'];
    });
  }

  Future<void> _fetchRoleClaims() async {
    setState(() => _loading = true);

    try {
      // LẤY TOKEN từ SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Token không tồn tại, cần đăng nhập lại');
      }

      final response = await http.get(
        Uri.parse('${Config_URL.baseUrl}RoleClaim/admin'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 STATUS: ${response.statusCode}');
      print('📥 BODY: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> claims = json.decode(response.body);

        setState(() {
          _permissions = {
            for (var claim in claims) claim.toString(): true,
          };
          _selectAll = _permissions.values.every((v) => v);
          _loading = false;
        });
      } else {
        throw Exception('Lỗi: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _toggleAllPermissions(bool? value) {
    setState(() {
      _selectAll = value!;
      _permissions.updateAll((key, _) => _selectAll);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý quyền')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown chọn Role
                  Row(
                    children: [
                      const Text('Role:'),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRole = newValue!;
                              _fetchRoleClaims();
                            });
                          },
                          items: _availableRoles
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Checkbox chọn tất cả
                  Row(
                    children: [
                      Checkbox(
                        value: _selectAll,
                        onChanged: _toggleAllPermissions,
                      ),
                      const Text('Chọn tất cả quyền'),
                    ],
                  ),
                  const Divider(),

                  // Danh sách quyền (checkbox)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _permissions.length,
                    itemBuilder: (context, index) {
                      final key = _permissions.keys.elementAt(index);
                      return CheckboxListTile(
                        title: Text(key),
                        value: _permissions[key],
                        onChanged: (bool? value) {
                          setState(() {
                            _permissions[key] = value!;
                            _selectAll = _permissions.values.every((v) => v);
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Các nút thao tác dạng hàng dọc
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // TODO: call POST /RoleClaim/add
                        },
                        child: const Text('Thêm quyền'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: call POST /RoleClaim/remove
                        },
                        child: const Text('Xóa quyền'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminScreen(),
                            ),
                          );
                        },
                        child: const Text('Đi đến Admin Screen'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
