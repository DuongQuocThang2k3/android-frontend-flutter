import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/api_client.dart';
import '../../shared_preferences/token_manager.dart';

class PaymentScreen extends StatefulWidget {
  final String productName;
  final double price;
  final String userPhone;
  final String userAddress;

  const PaymentScreen({
    super.key,
    required this.productName,
    required this.price,
    required this.userPhone,
    required this.userAddress,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;
  final ApiClient _apiClient = ApiClient();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final session = await TokenManager.getSession();
    if (session != null) {
      try {
        final data = json.decode(session) as Map<String, dynamic>;
        // Giả sử thông tin user được lưu dưới key 'user_info'
        final userJson = data['user_info'] as Map<String, dynamic>;
        _user = UserModel.fromJson(userJson);
        UserModel.setCurrentUser(_user!);
      } catch (e) {
        debugPrint("Lỗi parse session: $e");
      }
    }
    // Khởi tạo các controller với dữ liệu từ user (nếu có), hoặc dùng giá trị truyền vào
    _nameController = TextEditingController(text: _user?.fullName ?? '');
    _phoneController =
        TextEditingController(text: _user?.phoneNumber ?? widget.userPhone);
    _addressController =
        TextEditingController(text: _user?.address ?? widget.userAddress);
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _user?.id ?? await TokenManager.getUserId();
      final token = await TokenManager.getToken();
      final cart = await TokenManager.getCart();

      if (userId == null || token == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      // Tạo orderDetails từ cart nếu có, hoặc tạo mặc định nếu cart rỗng
      List<Map<String, dynamic>> orderDetails;
      if (cart.isEmpty) {
        orderDetails = [
          {
            "id": 0,
            "orderId": 0,
            "order": null,
            "productType": "Product",
            "productId": 1, // Thay thế bằng ID thực nếu cần
            "petId": 0,
            "quantity": 1,
            "price": widget.price,
          }
        ];
      } else {
        orderDetails = cart
            .map((item) => {
                  "id": 0,
                  "orderId": 0,
                  "order": null,
                  "productType": item.productType ?? "Product",
                  "productId": item.productId,
                  "petId": 0,
                  "quantity": item.quantity,
                  "price": item.unitPrice,
                })
            .toList();
      }

      final orderData = {
        "orderId": 0,
        "userId": userId,
        "orderDate": DateTime.now().toIso8601String(),
        "totalPrice": widget.price,
        "status": "Pending",
        "orderDetails": orderDetails,
        // Thông tin người dùng gửi kèm đơn hàng
        "user": {
          "id": userId,
          "fullName": _nameController.text,
          "phoneNumber": _phoneController.text,
          "address": _addressController.text,
        }
      };

      // Sử dụng ApiClient để gọi API đặt hàng
      final response = await _apiClient.post(
        'Order',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: orderData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Xóa giỏ hàng sau khi đặt hàng thành công
        await TokenManager.clearCart();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(
          'Lỗi khi đặt hàng. Mã lỗi: ${response.statusCode}\nNội dung: ${response.body}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu thông tin user chưa được nạp, hiển thị loading
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh Toán'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thẻ thông tin sản phẩm
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.productName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Giá: ${widget.price.toStringAsFixed(0)} VND',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Thẻ thông tin người mua
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin người mua:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Họ và Tên *',
                          hintText: 'Nhập họ và tên của bạn',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại *',
                          hintText: 'Nhập số điện thoại của bạn',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.phone),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Địa chỉ *',
                          hintText: 'Nhập địa chỉ giao hàng của bạn',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.location_on),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '* Thông tin bắt buộc',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Nút xác nhận thanh toán
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    if (_nameController.text.isEmpty ||
                        _phoneController.text.isEmpty ||
                        _addressController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                                content:
                                    Text('Vui lòng điền đầy đủ thông tin!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                    }
                    _placeOrder();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'XÁC NHẬN THANH TOÁN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
