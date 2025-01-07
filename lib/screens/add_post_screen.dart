import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tenController = TextEditingController();
  final TextEditingController _moTaController = TextEditingController();
  final TextEditingController _anhDaiDienController = TextEditingController();
  final TextEditingController _hinhAnhController = TextEditingController();

  // Gửi dữ liệu lên API
  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> postData = {
        'ten': _tenController.text,
        'moTa': _moTaController.text,
        'anhDaiDien': _anhDaiDienController.text,
        'hinhAnh': _hinhAnhController.text,
      };

      final response = await http.post(
        Uri.parse('https://foundgreenpen14.conveyor.cloud/api/PostApi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(postData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context, true); // Trả về true để làm mới danh sách bài đăng
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng bài thất bại!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Bài Đăng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _tenController,
                  decoration: const InputDecoration(labelText: 'Tên người đăng'),
                  validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
                ),
                TextFormField(
                  controller: _moTaController,
                  decoration: const InputDecoration(labelText: 'Mô tả bài đăng'),
                  validator: (value) => value!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                ),
                TextFormField(
                  controller: _anhDaiDienController,
                  decoration: const InputDecoration(labelText: 'Link Ảnh Đại Diện'),
                  validator: (value) => value!.isEmpty ? 'Vui lòng nhập link ảnh đại diện' : null,
                ),
                TextFormField(
                  controller: _hinhAnhController,
                  decoration: const InputDecoration(labelText: 'Link Ảnh Bài Đăng'),
                  validator: (value) => value!.isEmpty ? 'Vui lòng nhập link ảnh bài đăng' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitPost,
                  child: const Text('Đăng Bài'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}