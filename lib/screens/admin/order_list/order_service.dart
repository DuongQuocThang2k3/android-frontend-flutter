import 'dart:convert';

import '../../../models/order.dart';
import '../../../services/api_client.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  /// Lấy danh sách tất cả đơn hàng
  Future<List<Order>> fetchOrders() async {
    // Sửa endpoint thành '/orders' nếu API backend của bạn định nghĩa như vậy.
    final resp = await _apiClient.get('Order');
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load orders: ${resp.statusCode}');
  }

  /// Lấy chi tiết một đơn hàng theo id
  Future<Order> fetchOrderDetail(int id) async {
    final resp = await _apiClient.get('Order/$id');
    if (resp.statusCode == 200) {
      return Order.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load order $id: ${resp.statusCode}');
  }

  /// Tạo đơn hàng mới
  Future<Order> createOrder(Order order) async {
    final resp = await _apiClient.post('Order', body: order.toJson());
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return Order.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create order: ${resp.statusCode}');
  }

  /// Cập nhật đơn hàng (toàn bộ đơn hàng)
  Future<Order> updateOrder(Order order) async {
    final resp =
        await _apiClient.put('Order/${order.orderId}', body: order.toJson());
    if (resp.statusCode == 200) {
      return Order.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw Exception(
        'Failed to update order ${order.orderId}: ${resp.statusCode}');
  }

  /// Cập nhật trạng thái đơn hàng (chỉ cập nhật trạng thái)
  Future<Order> updateOrderStatus(int orderId, String status) async {
    final payload = {'status': status};
    final resp = await _apiClient.put('Order/$orderId', body: payload);
    if (resp.statusCode == 200) {
      return Order.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw Exception(
        'Failed to update order status for $orderId: ${resp.statusCode}');
  }

  /// Xóa đơn hàng
  Future<void> deleteOrder(int id) async {
    final resp = await _apiClient.delete('Order/$id');
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Failed to delete order $id: ${resp.statusCode}');
    }
  }
}
