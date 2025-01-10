import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Auth/login_screen.dart';
import '../payment_detail/payment_detail_screen.dart';
import '../payment_detail/shopping_cart_screen.dart';

class PetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetDetailScreen({Key? key, required this.pet}) : super(key: key);

  Future<void> _addToCart(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('shopping_cart') ?? [];

    cartItems.add(jsonEncode(pet));
    await prefs.setStringList('shopping_cart', cartItems);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sản phẩm đã được thêm vào giỏ hàng!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pet['name'],
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShoppingCartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh sản phẩm
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: pet['images'] != null && pet['images'].isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    pet['images'][0]['url'],
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text(
                      'Không có hình ảnh',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tên sản phẩm
              Text(
                pet['name'],
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                'Giá: ${pet['price']} VND',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blue,
                ),
              ),

              Text(
                'Mô tả:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                pet['description'] ?? 'Không có mô tả',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              Text(
                'Tình trạng: ${pet['status']}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                ),
              ),


              const SizedBox(height: 24),

              // Nút Thêm vào giỏ hàng
              ElevatedButton.icon(
                onPressed: () => _addToCart(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),

              // Nút Mua Ngay
              ElevatedButton.icon(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? token = prefs.getString('jwt_token');

                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Bạn cần đăng nhập để thanh toán'),
                        action: SnackBarAction(
                          label: 'Đăng nhập',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    String name = prefs.getString('name') ?? 'Người dùng';
                    String phone = prefs.getString('phone') ?? 'Chưa cập nhật';
                    String address = prefs.getString('address') ?? 'Chưa cập nhật';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          productName: pet['name'] ?? 'Tên sản phẩm',
                          price: double.tryParse(pet['price'].toString()) ?? 0.0,
                          userName: name,
                          userPhone: phone,
                          userAddress: address,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.payment),
                label: const Text(
                  'Mua ngay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
