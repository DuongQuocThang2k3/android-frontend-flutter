import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_cherry_pet_shop/models/cart_item.dart';
import 'package:the_cherry_pet_shop/shared_preferences/token_manager.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cart = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final cart = await TokenManager.getCart();
    setState(() => _cart = cart);
  }

  double get _totalAll => _cart.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> _updateCart() async {
    await TokenManager.saveCart(_cart);
    setState(() {});
  }

  String _formatVnd(double value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: _cart.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.grey),
              itemBuilder: (context, i) {
                final item = _cart[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    title: Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Đơn giá: ${_formatVnd(item.unitPrice)}\nSố lượng: ${item.quantity}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: _buildQuantityControl(item, i),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
          _buildCheckoutSection(),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(CartItem item, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () {
            if (item.quantity > 1) {
              item.quantity--;
              _updateCart();
            }
          },
        ),
        Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            item.quantity++;
            _updateCart();
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            _cart.removeAt(index);
            _updateCart();
          },
        ),
      ],
    );
  }

  Widget _buildCheckoutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _cart.isEmpty
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thanh toán thành công')),
                    );
                    TokenManager.clearCart().then((_) => _loadCart());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tổng tất cả: ${_formatVnd(_totalAll)}',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
