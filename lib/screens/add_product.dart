import 'package:flutter/material.dart';
import '../config/config_url.dart';
import '../models/productPost.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProductScreen extends StatelessWidget {
  final String baseUrl = '${Config_URL.baseUrl}ProductApi';

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController(); // Controller cho URL ảnh

  Future<void> addProduct(BuildContext context) async {
    productPost newPost = productPost(
      id: 0, // Backend tự tạo ID
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      image: _imageController.text, // Lấy URL ảnh từ trường nhập liệu
    );

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newPost.toJson()),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true); // Quay lại màn hình trước và báo thành công
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price')),
            TextField(controller: _imageController, decoration: const InputDecoration(labelText: 'Image URL')), // Thêm trường cho ảnh
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => addProduct(context),
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
