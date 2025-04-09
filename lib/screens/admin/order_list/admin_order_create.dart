import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/models/order.dart';
import 'package:the_cherry_pet_shop/models/order_detail.dart';
import 'package:the_cherry_pet_shop/models/petItem.dart';
import 'package:the_cherry_pet_shop/models/product_model.dart';
import 'package:the_cherry_pet_shop/models/user_model.dart';

import '../pet_list/cache_pet.dart';
import '../product_list/cache_product.dart';
import 'order_service.dart';

class AdminOrderCreate extends StatefulWidget {
  const AdminOrderCreate({Key? key}) : super(key: key);

  @override
  _AdminOrderCreateState createState() => _AdminOrderCreateState();
}

class _AdminOrderCreateState extends State<AdminOrderCreate> {
  final OrderService _service = OrderService();
  final _formKey = GlobalKey<FormState>();

  // Controllers cho thông tin User
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Controllers cho OrderDetail (số lượng, giá)
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _priceController = TextEditingController();

  // Controller và danh sách cho lựa chọn của Pet
  final TextEditingController _petSearchController = TextEditingController();
  List<PetItem> _petOptions = [];
  List<PetItem> _filteredPetOptions = [];
  PetItem? _selectedPet;

  // Controller và danh sách cho lựa chọn của Product
  final TextEditingController _productSearchController =
      TextEditingController();
  List<Product> _productOptions = [];
  List<Product> _filteredProductOptions = [];
  Product? _selectedProduct;

  // Loại đối tượng: 'product' hay 'pet'
  String _productType = 'product';

  bool _isSaving = false;
  bool _isLoadingOptions = true;

  @override
  void initState() {
    super.initState();
    _loadOptions();
    // Lắng nghe thay đổi tìm kiếm cho Pet
    _petSearchController.addListener(() {
      final query = _petSearchController.text.toLowerCase();
      setState(() {
        _filteredPetOptions = query.isEmpty
            ? _petOptions
            : _petOptions
                .where((pet) => pet.name.toLowerCase().contains(query))
                .toList();
      });
    });
    // Lắng nghe thay đổi tìm kiếm cho Product
    _productSearchController.addListener(() {
      final query = _productSearchController.text.toLowerCase();
      setState(() {
        _filteredProductOptions = query.isEmpty
            ? _productOptions
            : _productOptions
                .where((product) => product.name.toLowerCase().contains(query))
                .toList();
      });
    });
  }

  /// Tải danh sách lựa chọn từ cache cho cả Pet và Product
  Future<void> _loadOptions() async {
    try {
      final pets = await CachePet.loadPets();
      final products = await CacheProduct.loadProducts();
      setState(() {
        _petOptions = pets;
        _filteredPetOptions = pets;
        _productOptions = products;
        _filteredProductOptions = products;
        _isLoadingOptions = false;
      });
    } catch (e) {
      setState(() {
        _petOptions = [];
        _filteredPetOptions = [];
        _productOptions = [];
        _filteredProductOptions = [];
        _isLoadingOptions = false;
      });
      debugPrint('Lỗi load options: $e');
    }
    debugPrint("Pet options loaded: ${_petOptions.length}");
    debugPrint("Product options loaded: ${_productOptions.length}");
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    // Kiểm tra đã chọn đối tượng hay chưa theo _productType
    if (_productType.toLowerCase() == 'pet' && _selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa chọn thú cưng')),
      );
      return;
    }
    if (_productType.toLowerCase() == 'product' && _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa chọn sản phẩm')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Tạo đối tượng UserModel
    final user = UserModel(
      id: _userIdController.text.trim(),
      username: _userNameController.text.trim(),
      email: _emailController.text.trim(),
      fullName: _userNameController.text.trim(),
      role: 'User',
      emailConfirmed: false,
      twoFactorEnabled: false,
      lockoutEnabled: false,
      accessFailedCount: 0,
      token: '',
    );

    int quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    double totalPrice = quantity * price;

    OrderDetail orderDetail = OrderDetail(
      id: 0,
      orderId: 0,
      // Server sẽ tự gán id mới
      productType: _productType,
      productId: _productType.toLowerCase() == 'product'
          ? _selectedProduct?.productId
          : null,
      petId: _productType.toLowerCase() == 'pet' ? _selectedPet?.petId : null,
      quantity: quantity,
      price: price,
    );

    Order newOrder = Order(
      orderId: 0,
      // Server tự gán id mới
      userId: user.id,
      user: user,
      orderDate: DateTime.now(),
      totalPrice: totalPrice,
      status: 'Pending',
      orderDetails: [orderDetail],
    );

    try {
      await _service.createOrder(newOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo đơn hàng thành công')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo đơn hàng: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _petSearchController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Widget hiển thị lựa chọn đối tượng theo _productType
    Widget selectionWidget() {
      if (_isLoadingOptions) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_productType.toLowerCase() == 'pet') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _petSearchController,
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm thú cưng',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PetItem>(
              isExpanded: true,
              hint: const Text('Chọn thú cưng'),
              value: _selectedPet,
              items: _filteredPetOptions
                  .map((pet) => DropdownMenuItem<PetItem>(
                        value: pet,
                        child: Text(
                            pet.name.isNotEmpty ? pet.name : 'Không có tên'),
                      ))
                  .toList(),
              onChanged: (pet) {
                setState(() {
                  _selectedPet = pet;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn thú cưng';
                }
                return null;
              },
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _productSearchController,
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm sản phẩm',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Product>(
              isExpanded: true,
              hint: const Text('Chọn sản phẩm'),
              value: _selectedProduct,
              items: _filteredProductOptions
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
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn sản phẩm';
                }
                return null;
              },
            ),
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đơn hàng mới'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Thông tin User
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(labelText: 'User ID'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập User ID' : null,
              ),
              TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập Username' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập Email' : null,
              ),
              const Divider(height: 32),
              // Chọn loại sản phẩm
              DropdownButtonFormField<String>(
                value: _productType,
                decoration: const InputDecoration(labelText: 'Loại sản phẩm'),
                items: <String>['product', 'pet']
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _productType = value ?? 'product';
                    _selectedProduct = null;
                    _selectedPet = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Widget lựa chọn đối tượng (có thanh tìm kiếm và dropdown)
              selectionWidget(),
              const SizedBox(height: 16),
              // Thông tin OrderDetail khác
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Số lượng'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập số lượng' : null,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập giá sản phẩm' : null,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              _isSaving
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createOrder,
                        child: const Text('Tạo đơn hàng'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
