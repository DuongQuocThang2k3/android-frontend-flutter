import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../models/product_model.dart';
import '../../shared_preferences/token_manager.dart';
import '../payment_detail/payment_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _p;

  @override
  void initState() {
    super.initState();
    _p = widget.product;
  }

  Future<void> _addToCart() async {
    final cart = await TokenManager.getCart();
    cart.add(CartItem(
      productType: 'Product',
      productId: _p.productId,
      name: _p.name,
      unitPrice: _p.price,
      quantity: 1,
      imageUrl: _p.images.first.imageUrl,
    ));
    await TokenManager.saveCart(cart);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm \"${_p.name}\" vào giỏ hàng!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_p.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          )
        ],
      ),
      body: Column(
        children: [
          Image.network(_p.images.first.imageUrl,
              height: 250, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_p.name, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text('Giá: ${_p.price.toStringAsFixed(0)} VND',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Mô tả: ${_p.description}'),
                const SizedBox(height: 8),
                Text('Số lượng: ${_p.quantity}'),
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
                            productName: _p.name,
                            price: _p.price,
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
