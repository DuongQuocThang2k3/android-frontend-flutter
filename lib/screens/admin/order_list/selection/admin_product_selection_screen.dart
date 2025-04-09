import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/models/product_model.dart';
import '../../product_list/cache_product.dart';

class AdminProductSelectionScreen extends StatefulWidget {
  const AdminProductSelectionScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductSelectionScreen> createState() =>
      _AdminProductSelectionScreenState();
}

class _AdminProductSelectionScreenState
    extends State<AdminProductSelectionScreen> {
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
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _products;
      });
    } else {
      setState(() {
        _filteredProducts = _products
            .where((product) => product.name.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await CacheProduct.loadProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmSelection() {
    if (_selectedProduct != null) {
      Navigator.pop(context, _selectedProduct);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sản phẩm')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Sản phẩm'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(height: 16),
                      // Dropdown hiển thị danh sách sản phẩm theo _filteredProducts
                      DropdownButtonFormField<Product>(
                        isExpanded: true,
                        hint: const Text('Chọn sản phẩm'),
                        value: _selectedProduct,
                        items: _filteredProducts
                            .map((product) => DropdownMenuItem<Product>(
                                  value: product,
                                  child: Text(product.name.isNotEmpty
                                      ? product.name
                                      : 'Không có tên'),
                                ))
                            .toList(),
                        onChanged: (product) {
                          setState(() {
                            _selectedProduct = product;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _confirmSelection,
                        child: const Text('Xác nhận'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
