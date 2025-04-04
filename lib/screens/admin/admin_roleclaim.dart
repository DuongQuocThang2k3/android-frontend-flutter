import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config_url.dart';
import '../../models/roleclaim_model.dart';
import 'admin_screen.dart';

class AdminRolePage extends StatefulWidget {
  const AdminRolePage({super.key});

  @override
  _AdminRolePageState createState() => _AdminRolePageState();
}

class _AdminRolePageState extends State<AdminRolePage> {
  // Sử dụng RoleClaimModel để lưu trữ quyền
  List<RoleClaimModel> _roleClaims = [];
  Map<String, bool> _permissionsMap = {}; // Map để dễ dàng kiểm tra quyền
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

      // Decode token để lấy role
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

        // Chuyển đổi dữ liệu từ API thành danh sách RoleClaimModel
        _roleClaims = claims.map((claim) {
          return RoleClaimModel.fromString(claim.toString());
        }).toList();

        // Tạo map để dễ dàng kiểm tra quyền
        _permissionsMap = {
          for (var claim in _roleClaims) claim.toString(): true,
        };

        // Thêm các quyền "all" cho mỗi resource nếu có đủ 4 quyền cơ bản
        _updateAllPermissions();

        setState(() => _loading = false);
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

  // Cập nhật quyền "all" cho mỗi resource
  void _updateAllPermissions() {
    final resources = _getUniqueResources();

    for (var resource in resources) {
      final hasAllBasicPermissions = ['view', 'create', 'edit', 'delete']
          .every((action) => _permissionsMap['$resource.$action'] == true);

      _permissionsMap['$resource.all'] = hasAllBasicPermissions;
    }
  }

  // Lấy danh sách các resource duy nhất
  Set<String> _getUniqueResources() {
    return _roleClaims.map((claim) => claim.resource).toSet();
  }

  // Nhóm quyền theo resource
  Map<String, Map<String, bool>> _groupPermissionsByResource() {
    final Map<String, Map<String, bool>> result = {};
    final resources = _getUniqueResources();

    for (var resource in resources) {
      result[resource] = {
        for (var action in actions)
          action: _permissionsMap['$resource.$action'] ?? false,
      };
    }

    return result;
  }

  // Thêm quyền mới
  Future<void> _addPermission(String resource, String action) async {
    try {
      setState(() => _loading = true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) throw Exception('Token không tồn tại.');

      // Tạo payload cho API
      final payload = {
        "roleName": _currentRole,
        "claimValue": "$resource.$action"
      };

      final response = await http.post(
        Uri.parse('${Config_URL.baseUrl}RoleClaim/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm quyền: $resource.$action')),
        );
      } else {
        throw Exception('Lỗi khi thêm quyền: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // Xóa quyền
  Future<void> _removePermission(String resource, String action) async {
    try {
      setState(() => _loading = true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) throw Exception('Token không tồn tại.');

      // Tạo payload cho API
      final payload = {
        "roleName": _currentRole,
        "claimValue": "$resource.$action"
      };

      final response = await http.post(
        Uri.parse('${Config_URL.baseUrl}RoleClaim/remove'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa quyền: $resource.$action')),
        );
      } else {
        throw Exception('Lỗi khi xóa quyền: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // Xử lý khi người dùng thay đổi quyền
  void _onPermissionChanged(String resource, String action, bool? value) async {
    final key = '$resource.$action';
    final newValue = value ?? false;
    final oldValue = _permissionsMap[key] ?? false;

    // Cập nhật UI trước để người dùng thấy phản hồi ngay lập tức
    setState(() {
      _permissionsMap[key] = newValue;
    });

    // Xử lý quyền "all"
    if (action == 'all') {
      // Nếu thay đổi quyền "all", cập nhật tất cả quyền con
      for (var act in ['view', 'create', 'edit', 'delete']) {
        final subKey = '$resource.$act';
        final oldSubValue = _permissionsMap[subKey] ?? false;

        // Cập nhật UI
        setState(() {
          _permissionsMap[subKey] = newValue;
        });

        // Gọi API nếu có sự thay đổi
        if (oldSubValue != newValue) {
          if (newValue) {
            await _addPermission(resource, act);
          } else {
            await _removePermission(resource, act);
          }
        }
      }
    } else {
      // Nếu thay đổi quyền con
      if (oldValue != newValue) {
        if (newValue) {
          await _addPermission(resource, action);
        } else {
          await _removePermission(resource, action);
        }
      }

      // Cập nhật trạng thái quyền "all"
      final allChecked = ['view', 'create', 'edit', 'delete']
          .every((act) => _permissionsMap['$resource.$act'] == true);

      setState(() {
        _permissionsMap['$resource.all'] = allChecked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupPermissionsByResource();

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
                      'Resource',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  ...actions.map((act) =>
                      DataColumn(
                        label: Text(
                          act[0].toUpperCase() + act.substring(1),
                          style: const TextStyle(fontSize: 11),
                        ),
                      )),
                ],
                rows: grouped.entries.map((entry) {
                  final resource = entry.key;
                  final permissions = entry.value;

                  return DataRow(
                    cells: [
                      DataCell(Text(resource,
                          style: const TextStyle(fontSize: 11))),
                      ...actions.map((action) {
                        return DataCell(
                          Checkbox(
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                            value: permissions[action] ?? false,
                            onChanged: (val) =>
                                _onPermissionChanged(
                                    resource, action, val),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),

                  const SizedBox(height: 20),

                  // Nút để làm mới dữ liệu
            ElevatedButton.icon(
              onPressed: _fetchRoleClaims,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới dữ liệu'),
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
      ),
    );
  }
}