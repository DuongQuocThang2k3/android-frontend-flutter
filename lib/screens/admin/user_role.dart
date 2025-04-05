import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config_url.dart';

class UserRoleModel {
  final String userName;
  final String roleName;

  UserRoleModel({
    required this.userName,
    required this.roleName,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      userName: json['userName'] ?? '',
      roleName: json['roleName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'roleName': roleName,
    };
  }
}

class UserRolePage extends StatefulWidget {
  const UserRolePage({Key? key}) : super(key: key);

  @override
  _UserRolePageState createState() => _UserRolePageState();
}

class _UserRolePageState extends State<UserRolePage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _userRoles = [];
  List<String> _allPossibleRoles = ['Admin', 'User']; // Define all possible roles
  bool _loading = false;
  bool _loadingUsers = true;
  List<dynamic> _allUsers = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  // Lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('Token không tồn tại.');
      }
      return token;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy token: $e')),
      );
      return null;
    }
  }

  // Lấy danh sách tất cả người dùng
  Future<void> _fetchAllUsers() async {
    setState(() {
      _loadingUsers = true;
      _errorMessage = null;
    });

    try {
      String? token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${Config_URL.baseUrl}Authenticate/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('users')) {
          setState(() {
            _allUsers = data['users'];
            _loadingUsers = false;
          });
        } else if (data is List<dynamic>) {
          setState(() {
            _allUsers = data;
            _loadingUsers = false;
          });
        } else {
          throw Exception('Định dạng phản hồi API không mong đợi');
        }
      } else {
        throw Exception(
            'Lỗi khi tải danh sách người dùng: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _loadingUsers = false;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Thêm người dùng vào vai trò
  Future<void> addUserToRole(UserRoleModel model) async {
    setState(() {
      _loading = true;
    });

    try {
      String? token = await _getToken();

      if (token != null) {
        final response = await http.post(
          Uri.parse('${Config_URL.baseUrl}UserRole/add'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(model.toJson()),
        );

        if (response.statusCode == 200) {
          print('User added to role');
          // Refresh the roles after adding
          await getRolesOfUser(_searchController.text);
          // Refresh all users to update the roles
          await _fetchAllUsers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm vai trò thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Lỗi: ${response.statusCode} - ${response.body}');
        }
      } else {
        throw Exception('Không tìm thấy token');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi thêm vai trò: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Xóa vai trò khỏi người dùng
  Future<void> removeUserFromRole(UserRoleModel model) async {
    setState(() {
      _loading = true;
    });
    try {
      String? token = await _getToken();

      if (token != null) {
        final response = await http.post(
          Uri.parse('${Config_URL.baseUrl}UserRole/remove'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(model.toJson()),
        );

        if (response.statusCode == 200) {
          print('User removed from role');
          // Refresh the roles after removing
          await getRolesOfUser(_searchController.text);
          // Refresh all users to update the roles
          await _fetchAllUsers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa vai trò thành công'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          throw Exception('Lỗi: ${response.statusCode} - ${response.body}');
        }
      } else {
        throw Exception('Không tìm thấy token');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xóa vai trò: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Lấy danh sách vai trò của người dùng
  Future<void> getRolesOfUser(String username) async {
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên người dùng')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _userRoles = []; // Clear previous roles
    });

    try {
      String? token = await _getToken();

      if (token != null) {
        final response = await http.get(
          Uri.parse('${Config_URL.baseUrl}UserRole/$username'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            _userRoles = List<String>.from(data);
          });
          print('User roles: $_userRoles');
        } else {
          throw Exception('Lỗi: ${response.statusCode} - ${response.body}');
        }
      } else {
        throw Exception('Không tìm thấy token');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _userRoles = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy vai trò: $e')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Lấy danh sách các vai trò mà người dùng không thuộc về
  List<String> getRolesNotAssigned() {
    return _allPossibleRoles.where((role) => !_userRoles.contains(role)).toList();
  }

  // Chọn người dùng từ danh sách
  void _selectUserFromList(String username) {
    _searchController.text = username;
    getRolesOfUser(username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý quyền người dùng',
          style: TextStyle(fontSize: 16),
        ),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Phần tìm kiếm và quản lý vai trò
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tìm kiếm người dùng
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
                            'Tìm kiếm người dùng:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập tên người dùng',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  getRolesOfUser(_searchController.text.trim());
                                },
                                icon: const Icon(Icons.search, size: 16),
                                label: const Text('Tìm'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  backgroundColor: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Danh sách role người dùng đang thuộc về
                  Text(
                    'Vai trò của người dùng: ${_searchController.text.isEmpty ? "Chưa chọn" : _searchController.text}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _userRoles.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Không có vai trò nào hoặc chưa chọn người dùng',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _userRoles.length,
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                  itemBuilder: (context, index) {
                                    final role = _userRoles[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        role,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.remove_circle,
                                          color: Colors.red.shade400,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          final model = UserRoleModel(
                                            userName:
                                                _searchController.text.trim(),
                                            roleName: role,
                                          );
                                          removeUserFromRole(model);
                                        },
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Danh sách role người dùng không thuộc về
                  Text(
                    'Vai trò có thể thêm:',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _searchController.text.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Vui lòng chọn người dùng trước',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : getRolesNotAssigned().isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Người dùng đã có tất cả vai trò',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: getRolesNotAssigned().length,
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                        height: 1,
                                        color: Colors.grey.shade200,
                                      ),
                                      itemBuilder: (context, index) {
                                        final role =
                                            getRolesNotAssigned()[index];
                                        return ListTile(
                                          dense: true,
                                          title: Text(
                                            role,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(
                                              Icons.add_circle,
                                              color: Colors.green.shade400,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              final model = UserRoleModel(
                                                userName: _searchController.text
                                                    .trim(),
                                                roleName: role,
                                              );
                                              addUserToRole(model);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider giữa hai phần
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

          // Phần danh sách tất cả người dùng
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách tất cả người dùng',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, size: 20),
                        onPressed: _fetchAllUsers,
                        tooltip: 'Làm mới danh sách',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loadingUsers
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? Center(
                              child: Text(
                                'Lỗi: $_errorMessage',
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : _allUsers.isEmpty
                              ? const Center(
                                  child: Text('Không có người dùng nào'),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: _allUsers.length,
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                  itemBuilder: (context, index) {
                                    final user = _allUsers[index];
                                    final username =
                                        user['username'] ?? 'Unknown';
                                    final roles = user['roles'] != null
                                        ? (user['roles'] as List).join(', ')
                                        : 'Chưa có vai trò';

                                    return ListTile(
                                      dense: true,
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue.shade100,
                                        radius: 16,
                                        child: Text(
                                          username.isNotEmpty
                                              ? username[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        username,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Vai trò: $roles',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      trailing: TextButton(
                                        child: const Text(
                                          'Chọn',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        onPressed: () {
                                          _selectUserFromList(username);
                                        },
                                      ),
                                      onTap: () {
                                        _selectUserFromList(username);
                                      },
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}