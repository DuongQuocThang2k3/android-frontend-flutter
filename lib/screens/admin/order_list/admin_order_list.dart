import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/order.dart';
import 'admin_order_create.dart';
import 'admin_order_detail.dart';
import 'order_service.dart';

class AdminOrderList extends StatefulWidget {
  const AdminOrderList({Key? key}) : super(key: key);

  @override
  _AdminOrderListState createState() => _AdminOrderListState();
}

class _AdminOrderListState extends State<AdminOrderList> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orders = await _orderService.fetchOrders();
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      developer.log('Error in _fetchOrders: $e');
      setState(() {
        _error = e.toString();
      });
      _showErrorSnackBar('Không thể tải danh sách đơn hàng: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToOrderDetail(Order order, {required bool isEditing}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminOrderDetail(
          orderId: order.orderId,
          isEditing: isEditing,
        ),
      ),
    );
    if (result == true) {
      _fetchOrders();
    }
  }

  void _navigateToCreateOrder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminOrderCreate()),
    );
    if (result == true) {
      _fetchOrders();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'chờ xử lý':
        return Colors.orange;
      case 'processing':
      case 'đang xử lý':
        return Colors.blue;
      case 'completed':
      case 'hoàn thành':
        return Colors.green;
      case 'cancelled':
      case 'đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Mã đơn hàng và trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng #${order.orderId}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Chip(
                  backgroundColor: _getStatusColor(order.status),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order.status,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      if (order.status.toLowerCase() == 'completed' ||
                          order.status.toLowerCase() == 'hoàn thành')
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            // Sửa: sử dụng order.user.userName thay vì fullName
            _buildInfoRow(Icons.person, 'Khách hàng', order.user.username),
            _buildInfoRow(
                Icons.calendar_today, 'Ngày đặt', _formatDate(order.orderDate)),
            _buildInfoRow(
                Icons.shopping_cart, 'Số SP', '${order.orderDetails.length}'),
            _buildInfoRow(Icons.attach_money, 'Tổng tiền',
                currencyFormatter.format(order.totalPrice)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      _navigateToOrderDetail(order, isEditing: false),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Xem'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _navigateToOrderDetail(order, isEditing: true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Sửa'),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[700]),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateOrder,
        tooltip: 'Thêm đơn hàng',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Lỗi: $_error',
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _fetchOrders,
                            child: const Text('Thử lại')),
                      ],
                    ),
                  )
                : _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.inbox, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Chưa có đơn hàng nào',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) =>
                            _buildOrderCard(_orders[index]),
                      ),
      ),
    );
  }
}
