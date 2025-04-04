import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config_url.dart'; // Import the Config_URL class

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

  // Lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token'); // Use 'jwt_token' as in the sample
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

  // Thêm người dùng vào vai trò
  Future<void> addUserToRole(UserRoleModel model) async {
    setState(() {
      _loading = true;
    });

    try {
      String? token = await _getToken();

      if (token != null) {
        final response = await http.post(
          Uri.parse('${Config_URL.baseUrl}UserRole/add'), // Use Config_URL
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm vai trò thành công')),
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
        SnackBar(content: Text('Lỗi thêm vai trò: $e')),
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
          Uri.parse('${Config_URL.baseUrl}UserRole/remove'), // Use Config_URL
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa vai trò thành công')),
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
        SnackBar(content: Text('Lỗi xóa vai trò: $e')),
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
          Uri.parse('${Config_URL.baseUrl}UserRole/$username'), // Use Config_URL
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
                  onPressed: () {
                    getRolesOfUser(_searchController.text.trim());
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Danh sách role người dùng đang thuộc về
            const Text('Role user thuộc về:'),
            Container(
              height: 150,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _userRoles.isEmpty
                  ? const Center(child: Text('Không có vai trò nào'))
                  : ListView.builder(
                itemCount: _userRoles.length,
                itemBuilder: (context, index) {
                  final role = _userRoles[index];
                  return ListTile(
                    title: Text(role),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        final model = UserRoleModel(
                            userName: _searchController.text.trim(),
                            roleName: role);
                        removeUserFromRole(model);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Danh sách role người dùng không thuộc về
            const Text('Role user không thuộc về:'),
            Container(
              height: 150,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: getRolesNotAssigned().length,
                itemBuilder: (context, index) {
                  final role = getRolesNotAssigned()[index];
                  return ListTile(
                    title: Text(role),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final model = UserRoleModel(
                            userName: _searchController.text.trim(),
                            roleName: role);
                        addUserToRole(model);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}