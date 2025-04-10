import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/order.dart';
import '../../../models/order_detail.dart';
import 'order_service.dart';

class AdminOrderDetail extends StatefulWidget {
  final int orderId;
  final bool isEditing;

  const AdminOrderDetail({
    Key? key,
    required this.orderId,
    required this.isEditing,
  }) : super(key: key);

  @override
  _AdminOrderDetailState createState() => _AdminOrderDetailState();
}

class _AdminOrderDetailState extends State<AdminOrderDetail> {
  final OrderService _service = OrderService();
  Order? _order;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _selectedStatus;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  // Danh sách trạng thái đơn hàng (có thể chỉnh lại sao cho phù hợp với backend)
  final List<String> _orderStatuses = [
    'Chờ xử lý',
    'Đang xử lý',
    'Đã giao hàng',
    'Hoàn thành',
    'Đã hủy',
  ];

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
      final order = await _service.fetchOrderDetail(widget.orderId);
      setState(() {
        _order = order;
        // Giả sử khi lấy đơn hàng từ API, ta sử dụng trường userName để hiển thị tên khách hàng.
        _selectedStatus = order.status;
      });
    } catch (e) {
      developer.log('Error loading order: $e');
      setState(() => _error = e.toString());
      _showErrorSnackBar('Không thể tải thông tin đơn hàng: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus() async {
    if (_selectedStatus == null || _selectedStatus == _order?.status) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Tạo mới đối tượng Order với status đã cập nhật, giữ lại các trường khác từ _order.
      final updatedOrder = Order(
        orderId: _order!.orderId,
        userId: _order!.userId,
        user: _order!.user,
        orderDate: _order!.orderDate,
        totalPrice: _order!.totalPrice,
        status: _selectedStatus!,
        orderDetails: _order!.orderDetails,
      );
      final result = await _service.updateOrder(updatedOrder);
      setState(() {
        _order = result;
        _isSaving = false;
      });

      _showSuccessSnackBar('Đã cập nhật trạng thái đơn hàng thành công');
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSaving = false);
      _showErrorSnackBar('Không thể cập nhật trạng thái đơn hàng: $e');
    }
  }

  Future<void> _deleteOrder() async {
    try {
      await _service.deleteOrder(widget.orderId);
      _showSuccessSnackBar('Đã xóa đơn hàng thành công');
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackBar('Không thể xóa đơn hàng: $e');
    }
  }

  void _confirmDeleteOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrder();
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(List<OrderDetail> details) {
    return Column(
      children: details.map((detail) {
        String itemType = '';
        String itemId = '';

        if (detail.productType.toLowerCase().contains('pet') &&
            detail.petId != null) {
          itemType = 'Thú cưng';
          itemId = '${detail.petId}';
        } else if (detail.productId != null) {
          itemType = 'Sản phẩm';
          itemId = '${detail.productId}';
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(itemType.isNotEmpty ? itemType.substring(0, 1) : '?'),
            ),
            title: Text(
              '$itemType #$itemId',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              'Loại: ${detail.productType}',
              style: const TextStyle(fontSize: 13),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'SL: ${detail.quantity}',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  currencyFormatter.format(detail.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cập nhật trạng thái đơn hàng:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              items: _orderStatuses.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: widget.isEditing
                  ? (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    }
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.isEditing)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _updateOrderStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Cập nhật trạng thái'),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết đơn hàng #${widget.orderId}',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.blue,
        actions: [
          if (!_isLoading && _order != null) ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadOrder,
              tooltip: 'Làm mới',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDeleteOrder,
              tooltip: 'Xóa đơn hàng',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: $_error',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrder,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _order == null
                  ? const Center(
                      child: Text(
                        'Không tìm thấy thông tin đơn hàng',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailSection('Thông tin đơn hàng', [
                            _buildDetailRow(
                                'Mã đơn hàng', '${_order!.orderId}'),
                            _buildDetailRow(
                                'Ngày đặt', _formatDate(_order!.orderDate)),
                            _buildDetailRow('Tổng tiền',
                                currencyFormatter.format(_order!.totalPrice)),
                            _buildDetailRow('Trạng thái', _order!.status),
                          ]),
                          _buildDetailSection('Thông tin khách hàng', [
                            // Sửa: hiển thị userName thay vì fullName và loại bỏ các trường Phone/Address
                            _buildDetailRow(
                                'Tên người dùng', _order!.user.username),
                            _buildDetailRow('Email', _order!.user.email),
                          ]),
                          _buildDetailSection('Sản phẩm trong đơn hàng', [
                            _buildOrderItems(_order!.orderDetails),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  'Tổng cộng:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  currencyFormatter.format(_order!.totalPrice),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          ]),
                          if (widget.isEditing)
                            _buildDetailSection(
                                'Cập nhật đơn hàng', [_buildStatusDropdown()]),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }
}
