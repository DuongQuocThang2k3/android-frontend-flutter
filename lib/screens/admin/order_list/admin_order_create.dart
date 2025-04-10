import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/models/order.dart';
import 'package:the_cherry_pet_shop/models/order_detail.dart';
import 'package:the_cherry_pet_shop/models/petItem.dart';
import 'package:the_cherry_pet_shop/models/product_model.dart';
import 'package:the_cherry_pet_shop/models/user_model.dart';
import 'package:the_cherry_pet_shop/screens/admin/order_list/selection/admin_pet_selection_screen.dart';
import 'package:the_cherry_pet_shop/screens/admin/order_list/selection/admin_product_selection_screen.dart';

import '../pet_list/cache_pet.dart';
import '../product_list/cache_product.dart';
import 'order_service.dart';

/// Lớp hỗ trợ lưu trữ dữ liệu của một hàng order detail item
class _OrderDetailItem {
  String type; // "pet" hoặc "product"
  PetItem? selectedPet;
  Product? selectedProduct;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  _OrderDetailItem({this.type = 'product'})
      : quantityController = TextEditingController(text: '1'),
        priceController = TextEditingController();
}

class AdminOrderCreate extends StatefulWidget {
  const AdminOrderCreate({Key? key}) : super(key: key);

  @override
  _AdminOrderCreateState createState() => _AdminOrderCreateState();
}

class _AdminOrderCreateState extends State<AdminOrderCreate> {
  final OrderService _service = OrderService();
  final _formKey = GlobalKey<FormState>();

  // Thông tin user được lấy từ thông tin đăng nhập thành công (UserModel.currentUser)
  // Hãy đảm bảo rằng sau khi đăng nhập, biến tĩnh này đã được gán đầy đủ.
  UserModel? _currentUser = UserModel.currentUser;

  // Dữ liệu tải từ cache cho lựa chọn Pet và Product
  List<PetItem> _petOptions = [];
  List<Product> _productOptions = [];
  bool _isLoadingOptions = true;

  // Danh sách các hàng order detail
  List<_OrderDetailItem> orderDetailItems = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
    // Khởi tạo một hàng mặc định
    orderDetailItems.add(_OrderDetailItem());
  }

  Future<void> _loadOptions() async {
    try {
      // Lấy dữ liệu từ cache (hoặc cập nhật API nếu cần)
      final pets = await CachePet.loadPets();
      final products = await CacheProduct.loadProducts();
      setState(() {
        _petOptions = pets;
        _productOptions = products;
        _isLoadingOptions = false;
      });
    } catch (e) {
      setState(() {
        _petOptions = [];
        _productOptions = [];
        _isLoadingOptions = false;
      });
      debugPrint('Lỗi load options: $e');
    }
    debugPrint("Pet options loaded: ${_petOptions.length}");
    debugPrint("Product options loaded: ${_productOptions.length}");
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra có ít nhất 1 hàng có dữ liệu hợp lệ
    if (orderDetailItems.isEmpty ||
        orderDetailItems.every((item) =>
        (item.type == 'pet' && item.selectedPet == null) ||
            (item.type == 'product' && item.selectedProduct == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa chọn dữ liệu cho bất kỳ hàng nào')),
      );
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Thông tin người dùng không hợp lệ, hãy đăng nhập lại.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    List<OrderDetail> orderDetails = [];
    double totalPrice = 0.0;
    // Duyệt từng hàng order detail
    for (var item in orderDetailItems) {
      int quantity = int.tryParse(item.quantityController.text.trim()) ?? 1;
      double price = double.tryParse(item.priceController.text.trim()) ?? 0.0;
      if (item.type == 'pet' && item.selectedPet != null) {
        orderDetails.add(OrderDetail(
          id: 0,
          orderId: 0,
          productType: 'pet',
          productId: null,
          petId: item.selectedPet!.petId,
          quantity: quantity,
          price: price,
        ));
        totalPrice += quantity * price;
      } else if (item.type == 'product' && item.selectedProduct != null) {
        orderDetails.add(OrderDetail(
          id: 0,
          orderId: 0,
          productType: 'product',
          productId: item.selectedProduct!.productId,
          petId: null,
          quantity: quantity,
          price: price,
        ));
        totalPrice += quantity * price;
      }
    }

    if (orderDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa chọn dữ liệu hợp lệ cho bất kỳ hàng nào')),
      );
      setState(() => _isSaving = false);
      return;
    }

    Order newOrder = Order(
      orderId: 0,
      userId: _currentUser!.id, // _currentUser đã được kiểm tra ở trên
      user: _currentUser!,
      orderDate: DateTime.now(),
      totalPrice: totalPrice,
      status: 'Pending',
      orderDetails: orderDetails,
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
    for (var item in orderDetailItems) {
      item.quantityController.dispose();
      item.priceController.dispose();
    }
    super.dispose();
  }

  // Widget hiển thị mỗi hàng order detail sử dụng PetSelectionWidget hoặc ProductSelectionWidget
  Widget _buildOrderDetailItem(int index, _OrderDetailItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng đầu: chọn loại
            Row(
              children: [
                const Text('Loại: ', style: TextStyle(fontSize: 14)),
                DropdownButton<String>(
                  value: item.type,
                  items: const [
                    DropdownMenuItem(
                        value: 'pet',
                        child: Text('Thú cưng', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(
                        value: 'product',
                        child: Text('Sản phẩm', style: TextStyle(fontSize: 13))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      item.type = value ?? 'product';
                      // Reset dữ liệu khi chuyển đổi loại
                      item.selectedPet = null;
                      item.selectedProduct = null;
                      item.priceController.clear();
                    });
                  },
                ),
                const Spacer(),
                if (orderDetailItems.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    onPressed: () {
                      setState(() {
                        orderDetailItems.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // Phần chọn: sử dụng widget chọn tùy theo loại
            item.type == 'pet'
                ? PetSelectionWidget(
              onSelected: (pet) {
                setState(() {
                  item.selectedPet = pet;
                  if (pet != null) {
                    item.priceController.text = pet.price.toString();
                  }
                });
              },
            )
                : ProductSelectionWidget(
              onSelected: (prod) {
                setState(() {
                  item.selectedProduct = prod;
                  if (prod != null) {
                    item.priceController.text = prod.price.toString();
                  }
                });
              },
            ),
            const SizedBox(height: 6),
            // Nếu có lựa chọn, hiển thị thông tin sản phẩm đã chọn
            if ((item.type == 'pet' && item.selectedPet != null) ||
                (item.type == 'product' && item.selectedProduct != null))
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    item.type == 'pet'
                        ? 'Đã chọn: ${item.selectedPet!.name}'
                        : 'Đã chọn: ${item.selectedProduct!.name}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            // Các trường nhập số lượng và giá cho hàng này
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Số lượng',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập số lượng' : null,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextFormField(
                    controller: item.priceController,
                    decoration: const InputDecoration(
                      labelText: 'Giá',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập giá' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Phần hiển thị thông tin tài khoản hiện tại (read-only)
  // Lấy thông tin từ biến tĩnh UserModel.currentUser được gán sau khi đăng nhập thành công.
  Widget userInfoSection() {
    if (UserModel.currentUser != null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(Icons.person, color: Colors.blue, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tài khoản: ${UserModel.currentUser!.username}\n'
                      'Email: ${UserModel.currentUser!.email}\n'
                      'Role: ${UserModel.currentUser!.role ?? 'N/A'}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đơn hàng mới', style: TextStyle(fontSize: 14)),
        backgroundColor: Colors.blue,
      ),
      // Cố định nút "Tạo đơn hàng" ở dưới
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: ElevatedButton(
          onPressed: _createOrder,
          child: _isSaving
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text('Tạo đơn hàng', style: TextStyle(fontSize: 13)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Hiển thị thông tin tài khoản (read-only)
              userInfoSection(),
              // Danh sách các hàng order detail
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderDetailItems.length,
                itemBuilder: (context, index) {
                  return _buildOrderDetailItem(index, orderDetailItems[index]);
                },
              ),
              const SizedBox(height: 8),
              // Nút "Thêm hàng" để thêm mới order detail item
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      orderDetailItems.add(_OrderDetailItem());
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm hàng', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
