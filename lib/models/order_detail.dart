class OrderDetail {
  final int id;
  final int orderId;
  final String productType;
  final int? productId;
  final int? petId;
  final int quantity;
  final double price;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.productType,
    this.productId,
    this.petId,
    required this.quantity,
    required this.price,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as int,
      orderId: json['orderId'] != null ? json['orderId'] as int : 0,
      productType: json['productType'] as String? ?? '',
      productId: json['productId'] != null ? json['productId'] as int : null,
      petId: json['petId'] != null ? json['petId'] as int : null,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productType': productType,
      'quantity': quantity,
      'price': price,
      'productId': productId,
      'petId': petId,
    };
  }

  OrderDetail copyWith({
    int? id,
    int? orderId,
    String? productType,
    int? productId,
    int? petId,
    int? quantity,
    double? price,
  }) {
    return OrderDetail(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productType: productType ?? this.productType,
      productId: productId ?? this.productId,
      petId: petId ?? this.petId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}
