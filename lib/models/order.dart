import 'order_detail.dart';

class Order {
  int orderId;
  String userId;
  DateTime orderDate;
  double totalPrice;
  String status;
  List<OrderDetail> orderDetails;

  Order({
    this.orderId = 0,
    required this.userId,
    required this.orderDate,
    required this.totalPrice,
    this.status = 'Pending',
    required this.orderDetails,
  });

  /// JSON cho POST, chưa có trường user
  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'userId': userId,
        'orderDate': orderDate.toIso8601String(),
        'totalPrice': totalPrice,
        'status': status,
        'orderDetails': orderDetails.map((d) => d.toJson()).toList(),
      };

  /// JSON cho POST, kèm thêm object user
  Map<String, dynamic> toJsonWithUser(Map<String, dynamic> userJson) {
    final m = toJson();
    m['user'] = userJson;
    return m;
  }
}