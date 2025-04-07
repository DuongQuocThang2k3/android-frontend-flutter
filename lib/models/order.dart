import 'order_detail.dart';
import 'user_model.dart';

class Order {
  final int orderId;
  final String userId;
  final UserModel user;
  final DateTime orderDate;
  final double totalPrice;
  final String status;
  final List<OrderDetail> orderDetails;

  Order({
    required this.orderId,
    required this.userId,
    required this.user,
    required this.orderDate,
    required this.totalPrice,
    required this.status,
    required this.orderDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] as int,
      userId: json['userId'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      orderDate: DateTime.parse(json['orderDate'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      orderDetails: json['orderDetails'] != null
          ? (json['orderDetails'] as List<dynamic>)
              .map((e) => OrderDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'user': user.toJson(),
      'orderDate': orderDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'orderDetails': orderDetails.map((d) => d.toJson()).toList(),
    };
  }
}
