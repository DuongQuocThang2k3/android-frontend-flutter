import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/productPost.dart';

class EditProductScreen extends StatefulWidget {
  final productPost product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  bool isLoading = false; // Quản lý trạng thái loading

  final String baseUrl = 'https://foundgreenpen14.conveyor.cloud/api/ProductApi';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _imageController = TextEditingController(text: widget.product.image);
  }

  // Kiểm tra tính hợp lệ của dữ liệu đầu vào
  bool _validateInputs() {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return false;
    }
    return true;
  }

  // Cập nhật sản phẩm
  Future<void> editProduct() async {
    if (!_validateInputs()) return;

    setState(() {
      isLoading = true;
    });

    final updatedProduct = productPost(
      id: widget.product.id,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      image: _imageController.text,
    );

    final response = await http.put(
      Uri.parse('$baseUrl/${widget.product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedProduct.toJson()),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );
      Navigator.pop(context, true); // Trở lại màn hình trước
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update pet: ${response.statusCode}\n${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator() // Hiển thị loading khi đang xử lý
                : ElevatedButton(
              onPressed: editProduct,
              child: const Text('Update Product'),
            ),
          ],
        ),
      ),
    );
  }
}
