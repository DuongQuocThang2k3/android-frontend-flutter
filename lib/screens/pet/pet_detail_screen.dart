import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../shared_preferences/token_manager.dart';
import '../payment_detail/cart_screen.dart';
import '../payment_detail/payment_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pet;

  const PetDetailScreen({Key? key, required this.pet}) : super(key: key);

  @override
  _PetDetailScreenState createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  late Map<String, dynamic> _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  Future<void> _addToCart() async {
    final cart = await TokenManager.getCart();
    cart.add(CartItem(
      productType: 'Pet',
      productId: _pet['petId'],
      name: _pet['name'],
      unitPrice: (_pet['price'] as num).toDouble(),
      quantity: 1,
      imageUrl: _pet['images'][0]['url'],
    ));
    await TokenManager.saveCart(cart);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm vào giỏ hàng!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pet['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Image.network(_pet['images'][0]['url'],
              height: 250, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_pet['name'], style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text('Giá: ${_pet['price']} VND',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Mô tả: ${_pet['description']}'),
                const SizedBox(height: 8),
                Text('Tình trạng: ${_pet['status']}'),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addToCart,
                    child: const Text('THÊM VÀO GIỎ HÀNG'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final phone =
                          await TokenManager.getUserPhone() ?? 'Chưa cập nhật';
                      final address = await TokenManager.getUserAddress() ??
                          'Chưa cập nhật';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            productName: _pet['name'],
                            price: (_pet['price'] as num).toDouble(),
                            userPhone: phone,
                            userAddress: address,
                          ),
                        ),
                      );
                    },
                    child: const Text('MUA NGAY'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
