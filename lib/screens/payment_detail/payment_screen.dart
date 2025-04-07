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
    Key? key,
    required this.productName,
    required this.price,
    required this.userPhone,
    required this.userAddress,
  }) : super(key: key);

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
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    // Load session and parse user
    final session = await TokenManager.getSession();
    if (session != null) {
      try {
        final data = json.decode(session) as Map<String, dynamic>;
        final userJson = data['user_info'] as Map<String, dynamic>;
        _user = UserModel.fromJson(userJson);
        UserModel.setCurrentUser(_user!);
      } catch (e) {
        debugPrint('Lỗi parse session: $e');
      }
    }

    // Await async getters
    final phone = _user != null ? await _user!.phoneNumber : widget.userPhone;
    final addr = _user != null ? await _user!.address : widget.userAddress;

    // Initialize controllers
    _nameController = TextEditingController(text: _user?.fullName ?? '');
    _phoneController = TextEditingController(text: phone);
    _addressController = TextEditingController(text: addr);

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
    setState(() => _isLoading = true);

    try {
      final username = _user?.username;
      final token = await TokenManager.getToken();
      final cart = await TokenManager.getCart();

      if (username == null || token == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      final orderDetails = cart.isNotEmpty
          ? cart
              .map((item) => {
                    'productType': item.productType ?? 'Product',
                    'productId': item.productId,
                    'quantity': item.quantity,
                    'price': item.unitPrice,
                  })
              .toList()
          : [
              {
                'productType': 'Product',
                'productId': 1,
                'quantity': 1,
                'price': widget.price,
              }
            ];

      final orderData = {
        'UserId': username,
        'orderDate': DateTime.now().toIso8601String(),
        'totalPrice': widget.price,
        'status': 'Pending',
        'orderDetails': orderDetails,
        'user': {
          'fullName': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        },
      };

      final resp = await _apiClient.post(
        'Order',
        body: orderData,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await TokenManager.clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Lỗi khi đặt hàng: ${resp.statusCode}\n${resp.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tài khoản: ${_user!.username}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.productName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Giá: ${widget.price.toStringAsFixed(0)} VND',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue)),
                      ]),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thông tin người mua:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Họ và Tên *',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
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
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
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
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            prefixIcon: const Icon(Icons.location_on),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        const Text('* Thông tin bắt buộc',
                            style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.red)),
                      ]),
                ),
              ),
              const SizedBox(height: 24),
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
                                  backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          _placeOrder();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('XÁC NHẬN THANH TOÁN',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
