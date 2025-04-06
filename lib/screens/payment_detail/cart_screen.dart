import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_cherry_pet_shop/models/cart_item.dart';
import 'package:the_cherry_pet_shop/screens/payment_detail/payment_screen.dart';
import 'package:the_cherry_pet_shop/shared_preferences/token_manager.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cart = [];
  bool _isLoading = false;

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

  Future<void> _proceedToCheckout() async {
    setState(() => _isLoading = true);

    try {
      // Check if user is logged in
      final token = await TokenManager.getToken();
      final session = await TokenManager.getSession();

      if (token == null || session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để thanh toán'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Get user information
      final phone = await TokenManager.getUserPhone() ?? '';
      final address = await TokenManager.getUserAddress() ?? '';

      // Navigate to payment screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              productName: 'Giỏ hàng (${_cart.length} sản phẩm)',
              price: _totalAll,
              userPhone: phone,
              userAddress: address,
            ),
          ),
        ).then((_) => _loadCart()); // Refresh cart when returning
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
            child: _cart.isEmpty
                ? const Center(
                    child: Text(
                      'Giỏ hàng trống',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: _cart.length,
              separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Colors.grey),
                    itemBuilder: (context, i) {
                final item = _cart[i];
                return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 4,
                  child: ListTile(
                    title: Text(item.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                      'Đơn giá: ${_formatVnd(item.unitPrice)}\nSố lượng: ${item.quantity}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
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
            onPressed: _cart.isEmpty || _isLoading ? null : _proceedToCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
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