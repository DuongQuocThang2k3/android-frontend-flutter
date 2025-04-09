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
      orderId: json['orderId'] != null ? json['orderId'] as int : 0,
      userId: json['userId'] as String? ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'] as String)
          : DateTime.now(),
      totalPrice: json['totalPrice'] != null
          ? (json['totalPrice'] as num).toDouble()
          : 0.0,
      status: json['status'] as String? ?? '',
      orderDetails: json['orderDetails'] != null
          ? (json['orderDetails'] as List<dynamic>).map((e) {
              var detailJson = e as Map<String, dynamic>;
              // Nếu detail không có orderId thì chèn giá trị từ đơn hàng cha.
              if (detailJson['orderId'] == null) {
                detailJson['orderId'] = json['orderId'];
              }
              return OrderDetail.fromJson(detailJson);
            }).toList()
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
