import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/productPost.dart';
import 'Auth/AddProductScreen.dart';
import 'Auth/AddProductScreen.dart';
import 'search_product.dart';
import 'add_product.dart';
import 'edit_product.dart';
import 'delete_product.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final SearchService searchService = SearchService();
  late Future<List<productPost>> _posts;
  List<productPost> _filteredProducts = []; // Danh sách sản phẩm đã lọc
  List<productPost> _products = []; // Danh sách sản phẩm gốc

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // Lấy danh sách sản phẩm khi trang được khởi tạo
  }

  // Lấy danh sách tất cả sản phẩm từ API
  Future<void> _fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('https://foundgreenpen14.conveyor.cloud/api/ProductApi'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<productPost> products = data.map((item) => productPost.fromJson(item)).toList();
        setState(() {
          _products = products; // Cập nhật danh sách sản phẩm gốc
          _filteredProducts = products; // Ban đầu hiển thị tất cả sản phẩm
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products')),
      );
    }
  }

  // Xử lý xóa sản phẩm
  Future<void> _deleteProduct(int productId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeleteProductScreen(
          productId: productId,
          onDeleteSuccess: () {
            setState(() {
              _fetchPosts(); // Làm mới danh sách khi xóa sản phẩm thành công
            });
          },
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _fetchPosts(); // Làm mới danh sách khi xóa sản phẩm
      });
    }
  }

  // Xử lý thêm sản phẩm
  Future<void> _addProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen()),
    );
    if (result == true) {
      setState(() {
        _fetchPosts(); // Làm mới danh sách sau khi thêm sản phẩm
      });
    }
  }

  // Xử lý sửa sản phẩm
  Future<void> _editProduct(BuildContext context, productPost product) async {
    final updatedProduct = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProductScreen(product: product)),
    );
    if (updatedProduct != null) {
      await http.put(
        Uri.parse('https://goodshinytrail60.conveyor.cloud/api/ProductApi/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedProduct.toJson()),
      );
      setState(() {
        _fetchPosts(); // Làm mới danh sách sau khi cập nhật
      });
    }
  }

  // Xử lý tìm kiếm sản phẩm theo ID hoặc tên
  void _searchProduct() async {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products; // Nếu chuỗi tìm kiếm rỗng, hiển thị tất cả sản phẩm
      } else {
        // Lọc các sản phẩm theo tên hoặc mô tả
        _filteredProducts = _products
            .where((product) =>
        (product.name?.toLowerCase().contains(query) ?? false) ||
            (product.description?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });

    // Nếu query không rỗng và không tìm thấy sản phẩm nào, có thể gọi API tìm kiếm theo ID
    if (query.isNotEmpty && _filteredProducts.isEmpty) {
      try {
        // Gọi API để tìm kiếm theo ID nếu không có kết quả lọc tên và mô tả
        final productById = await searchService.searchById(query);
        if (productById != null && productById.isNotEmpty) {
          setState(() {
            _filteredProducts = productById; // Thêm sản phẩm tìm thấy vào danh sách
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No products found for: $query')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load product for: $query')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchPosts(); // Làm mới danh sách khi bấm nút refresh
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addProduct, // Gọi chức năng thêm sản phẩm
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search', // Đổi nhãn để rõ ràng hơn
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchProduct, // Gọi hàm tìm kiếm sản phẩm
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ListTile(
                  title: Text(product.name ?? 'No name'),
                  subtitle: Text(product.description ?? 'No description'),
                  leading: product.image != null && product.image!.isNotEmpty
                      ? Image.network(product.image!)
                      : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editProduct(context, product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (product.id != null) {
                            _deleteProduct(product.id!); // Gọi hàm xóa sản phẩm
                          } else {
                            print("ID sản phẩm không hợp lệ.");
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
