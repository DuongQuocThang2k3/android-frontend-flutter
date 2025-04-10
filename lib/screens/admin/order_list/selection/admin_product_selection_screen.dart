import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../models/product_model.dart';
import '../../../../services/api_client.dart';

class ProductSelectionWidget extends StatefulWidget {
  final Function(Product?)? onSelected;

  const ProductSelectionWidget({Key? key, this.onSelected}) : super(key: key);

  @override
  _ProductSelectionWidgetState createState() => _ProductSelectionWidgetState();
}

class _ProductSelectionWidgetState extends State<ProductSelectionWidget> {
  final ApiClient _api = ApiClient();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _loadProducts();

    // Lắng nghe thay đổi tìm kiếm
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredProducts = query.isEmpty
            ? _products
            : _products
                .where((product) => product.name.toLowerCase().contains(query))
                .toList();
      });
    });
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final resp = await _api.get('Product');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          final products = data
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList();
          setState(() {
            _products = products;
            _filteredProducts = products;
          });
        } else {
          throw Exception('Dữ liệu trả về không đúng định dạng');
        }
      } else {
        throw Exception('Server error: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải sản phẩm: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Lỗi: $_error',
          style: const TextStyle(fontSize: 13, color: Colors.red),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thanh tìm kiếm
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Tìm kiếm sản phẩm',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        // Dropdown hiển thị danh sách sản phẩm đã lọc
        DropdownButtonFormField<Product>(
          isExpanded: true,
          hint: const Text('Chọn sản phẩm'),
          value: _selectedProduct,
          items: _filteredProducts
              .map((product) => DropdownMenuItem<Product>(
                    value: product,
                    child: Text(
                      product.name.isNotEmpty ? product.name : 'Không có tên',
                    ),
                  ))
              .toList(),
          onChanged: (product) {
            setState(() {
              _selectedProduct = product;
            });
            if (widget.onSelected != null) {
              widget.onSelected!(product);
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Vui lòng chọn sản phẩm';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        // In ra số lượng sản phẩm đã load
        Text(
          'Số lượng sản phẩm đã load: ${_filteredProducts.length}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        // Hiển thị thông tin của sản phẩm được chọn nếu có
        if (_selectedProduct != null) ...[
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Đã chọn: ${_selectedProduct!.name}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
