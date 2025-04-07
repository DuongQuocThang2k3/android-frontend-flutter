import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../services/api_client.dart';
import 'admin_order_detail.dart'; // Import file chi tiết đơn hàng

class AdminOrderList extends StatefulWidget {
  const AdminOrderList({Key? key}) : super(key: key);

  @override
  _AdminOrderListState createState() => _AdminOrderListState();
}

class _AdminOrderListState extends State<AdminOrderList> {
  final ApiClient _api = ApiClient();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;

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
      // ApiClient tự thêm header Authorization nếu cần
      final resp = await _api.get('Order');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          setState(() {
            _orders = data;
          });
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to load orders: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching orders: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToOrderDetail(int orderId, {required bool isEditing}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminOrderDetail(orderId: orderId, isEditing: isEditing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đơn hàng'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : _orders.isEmpty
                  ? const Center(child: Text('Chưa có đơn hàng nào'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
              title: Text(
                'Mã đơn hàng: ${order['orderId'] ?? 'N/A'}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ngày tạo: ${order['orderDate'] ?? 'N/A'}'),
                  Text('Khách hàng: ${order['customerName'] ?? 'N/A'}'),
                  Text('Trạng thái: ${order['status'] ?? 'N/A'}'),
                  Text('Tổng giá: ${order['totalPrice'] ?? 'N/A'} VND'),
                ],
              ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _navigateToOrderDetail(order['orderId'],
                                        isEditing: false);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.green),
                                  onPressed: () {
                                    _navigateToOrderDetail(order['orderId'],
                                        isEditing: true);
                                  },
                                ),
                              ],
                            ),
            ),
          );
        },
      ),
    );
  }
}
