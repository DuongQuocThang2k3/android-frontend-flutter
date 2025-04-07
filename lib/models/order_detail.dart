class OrderDetail {
  final int id;
  final int orderId;
  final String productType;
  final int productId;
  final int? petId;
  final int quantity;
  final double price;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.productType,
    required this.productId,
    this.petId,
    required this.quantity,
    required this.price,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      productType: json['productType'] as String,
      productId: json['productId'] as int,
      petId: json['petId'] as int?,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productType': productType,
      'productId': productId,
      if (petId != null) 'petId': petId,
      'quantity': quantity,
      'price': price,
    };
  }
}
