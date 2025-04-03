import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config_url.dart';
import 'admin_screen.dart';

class AdminRolePage extends StatefulWidget {
  const AdminRolePage({super.key});

  @override
  _AdminRolePageState createState() => _AdminRolePageState();
}

class _AdminRolePageState extends State<AdminRolePage> {
  Map<String, bool> _permissions = {};
  bool _loading = false;
  String? _currentRole;

  final List<String> actions = ['view', 'create', 'edit', 'delete', 'all'];

  @override
  void initState() {
    super.initState();
    _fetchRoleClaims();
  }

  Future<void> _fetchRoleClaims() async {
    setState(() => _loading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) throw Exception('Token không tồn tại.');

      // ✅ Decode token để lấy role
      Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
      String role = decodedToken['role'] ?? 'Không xác định';
      _currentRole = role;

      final response = await http.get(
        Uri.parse('${Config_URL.baseUrl}RoleClaim/$role'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> claims = json.decode(response.body);
        final Map<String, bool> fetchedPermissions = {
          for (var claim in claims) claim.toString(): true,
        };

        setState(() {
          _permissions = fetchedPermissions;
          _loading = false;
        });
      } else {
        throw Exception('Lỗi: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Map<String, Map<String, bool>> _groupPermissionsByModel() {
    final Map<String, Map<String, bool>> result = {};

    for (var entry in _permissions.entries) {
      final parts = entry.key.split('.');
      if (parts.length != 2) continue;

      final model = parts[0];
      final action = parts[1];

      result.putIfAbsent(
          model,
          () => {
                for (var act in actions) act: false,
              });

      if (actions.contains(action)) {
        result[model]![action] = entry.value;
      }
    }

    return result;
  }

  void _onPermissionChanged(String model, String action, bool? value) {
    final key = '$model.$action';

    setState(() {
      _permissions[key] = value ?? false;

      if (action == 'all') {
        for (var act in ['view', 'create', 'edit', 'delete']) {
          _permissions['$model.$act'] = value!;
        }
      } else {
        final allChecked = ['view', 'create', 'edit', 'delete']
            .every((act) => _permissions['$model.$act'] == true);
        _permissions['$model.all'] = allChecked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupPermissionsByModel();

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý quyền')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vai trò hiện tại:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _currentRole ?? 'Không xác định',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bảng quyền
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 30,
                      dataRowMinHeight: 28,
                      columnSpacing: 12,
                      columns: [
                        const DataColumn(
                          label: Text(
                            'Model',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                        ...actions.map((act) => DataColumn(
                              label: Text(
                                act[0].toUpperCase() + act.substring(1),
                                style: const TextStyle(fontSize: 11),
                              ),
                            )),
                      ],
                      rows: grouped.entries.map((entry) {
                        final model = entry.key;
                        return DataRow(
                          cells: [
                            DataCell(Text(model,
                                style: const TextStyle(fontSize: 11))),
                            ...actions.map((action) {
                              final key = '$model.$action';
                              return DataCell(
                                Checkbox(
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: _permissions[key] ?? false,
                                  onChanged: (val) =>
                                      _onPermissionChanged(model, action, val),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Các nút chức năng
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Gọi API thêm quyền
                        },
                        child: const Text('Thêm quyền'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Gọi API xóa quyền
                        },
                        child: const Text('Xóa quyền'),
                      ),
                      const SizedBox(height: 8),
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
