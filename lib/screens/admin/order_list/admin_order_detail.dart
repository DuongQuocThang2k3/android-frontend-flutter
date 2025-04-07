import 'package:flutter/material.dart';

import '../../../models/order.dart';
import '../../../models/order_detail.dart';
import 'order_service.dart';

class AdminOrderDetail extends StatefulWidget {
  final int orderId;

  const AdminOrderDetail(
      {Key? key, required this.orderId, required bool isEditing})
      : super(key: key);

  @override
  _AdminOrderDetailState createState() => _AdminOrderDetailState();
}

class _AdminOrderDetailState extends State<AdminOrderDetail> {
  final OrderService _service = OrderService();
  Order? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final o = await _service.fetchOrderDetail(widget.orderId);
      setState(() => _order = o);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(List<OrderDetail> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.map((d) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${d.productType} #${d.productId}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Số lượng: ${d.quantity}'),
                Text('Giá: ${d.price}'),
                if (d.petId != null) Text('Pet ID: ${d.petId}'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn #${widget.orderId}'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : _order == null
                  ? const Center(child: Text('Không tìm thấy đơn hàng'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Mã đơn hàng', '${_order!.orderId}'),
                          _buildDetailRow('Ngày đặt',
                              _order!.orderDate.toLocal().toString()),
                          _buildDetailRow('Khách hàng', _order!.user.fullName),
                          _buildDetailRow('Email', _order!.user.email),
                          _buildDetailRow(
                              'Tổng giá', '${_order!.totalPrice} VND'),
                          _buildDetailRow('Trạng thái', _order!.status),
                          const Divider(height: 32),
                          const Text('Chi tiết sản phẩm:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          // Nếu orderDetails null, truyền danh sách rỗng
                          _buildOrderDetails(_order!.orderDetails ?? []),
                        ],
                      ),
                    ),
    );
  }
}
