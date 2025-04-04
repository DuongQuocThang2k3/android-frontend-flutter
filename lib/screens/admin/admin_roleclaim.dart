import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  String _selectedRole = 'Admin'; // Mặc định chọn Admin
  final List<String> _availableRoles = [
    'Admin',
    'User'
  ]; // Danh sách vai trò có sẵn

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

      final response = await http.get(
        Uri.parse('${Config_URL.baseUrl}RoleClaim/$_selectedRole'),
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
        "roleName": _selectedRole,
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
          SnackBar(
            content:
                Text('Đã thêm quyền: $resource.$action cho $_selectedRole'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Lỗi khi thêm quyền: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
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
        "roleName": _selectedRole,
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
          SnackBar(
            content: Text('Đã xóa quyền: $resource.$action từ $_selectedRole'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception('Lỗi khi xóa quyền: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý quyền',
          style: TextStyle(fontSize: 16),
        ),
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown chọn vai trò
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chọn vai trò:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRole,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                ),
                                items: _availableRoles.map((String role) {
                                  return DropdownMenuItem<String>(
                                    value: role,
                                    child: Text(role),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null &&
                                      newValue != _selectedRole) {
                                    setState(() {
                                      _selectedRole = newValue;
                                      _permissionsMap.clear();
                                      _roleClaims.clear();
                                    });
                                    _fetchRoleClaims();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tiêu đề bảng quyền
                  Text(
                    'Danh sách quyền cho vai trò: $_selectedRole',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bảng quyền - Thiết kế lại để vừa với màn hình
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Tính toán chiều rộng khả dụng
                        final availableWidth =
                            constraints.maxWidth - 16; // Trừ đi padding

                        // Tính toán chiều rộng cột
                  final resourceColumnWidth = availableWidth *
                      0.3; // 30% cho cột resource
                  final actionColumnWidth = (availableWidth * 0.7) /
                      actions.length; // Phần còn lại chia đều cho các action

                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Table(
                      columnWidths: {
                        0: FixedColumnWidth(resourceColumnWidth),
                        for (int i = 0; i < actions.length; i++)
                          i + 1: FixedColumnWidth(actionColumnWidth),
                      },
                      border: TableBorder(
                        horizontalInside: BorderSide(color: Colors.grey
                            .shade200),
                        verticalInside: BorderSide(color: Colors.grey.shade200),
                      ),
                      children: [
                        // Header row
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              child: Text(
                                'Resource',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ...actions.map((act) =>
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 2),
                                  child: Center(
                                    child: Text(
                                      act[0].toUpperCase() + act.substring(1),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )),
                          ],
                        ),

                        // Data rows
                        ...grouped.entries.map((entry) {
                          final resource = entry.key;
                          final permissions = entry.value;

                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 4),
                                      child: Text(
                                        resource,
                                        style: TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    ...actions.map((action) => Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Checkbox(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: permissions[action] ??
                                                    false,
                                                onChanged: (val) =>
                                                    _onPermissionChanged(
                                                        resource, action, val),
                                              ),
                                            ),
                                          ),
                                        )),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    ),
            ),

                  const SizedBox(height: 20),

                  // Các nút chức năng
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _fetchRoleClaims,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text(
                      'Làm mới dữ liệu',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.dashboard, size: 16),
                    label: const Text(
                      'Quay lại Dashboard',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}