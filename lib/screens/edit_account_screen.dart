import 'package:flutter/material.dart';

class EditAccountScreen extends StatefulWidget {
  final String avatarUrl;
  final String name;
  final String email;
  final String phone;
  final String address;

  const EditAccountScreen({
    required this.avatarUrl,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    Key? key,
  }) : super(key: key);

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late String _avatarUrl;

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.avatarUrl;
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _addressController = TextEditingController(text: widget.address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa tài khoản'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(_avatarUrl),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Trả về dữ liệu đã chỉnh sửa
                Navigator.pop(context, {
                  'avatarUrl': _avatarUrl,
                  'name': _nameController.text,
                  'email': _emailController.text,
                  'phone': _phoneController.text,
                  'address': _addressController.text,
                });
              },
              child: const Text('Lưu thay đổi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
