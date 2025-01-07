import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeleteProductScreen extends StatefulWidget {
  final int productId;
  final Function onDeleteSuccess;
  final String baseUrl = 'https://foundgreenpen14.conveyor.cloud/api/ProductApi';

  DeleteProductScreen({
    Key? key,
    required this.productId,
    required this.onDeleteSuccess,
  }) : super(key: key);

  @override
  _DeleteProductScreenState createState() => _DeleteProductScreenState();
}

class _DeleteProductScreenState extends State<DeleteProductScreen> {
  bool isLoading = false;

  Future<void> deleteProduct(BuildContext context) async {
    setState(() {
      isLoading = true; // Đánh dấu đang xử lý
    });

    final response = await http.delete(Uri.parse('${widget.baseUrl}/${widget.productId}'));

    setState(() {
      isLoading = false; // Kết thúc xử lý
    });

    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );
      widget.onDeleteSuccess(); // Gọi callback để làm mới danh sách sản phẩm
      Navigator.pop(context, true); // Quay lại màn hình trước
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Product')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Hiển thị loader khi đang xử lý
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Are you sure you want to delete this product?'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => deleteProduct(context),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
