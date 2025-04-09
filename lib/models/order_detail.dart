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
      // Nếu không có orderId thì gán 0 (nếu đã có xử lý ở Order.fromJson thì trường này sẽ luôn có)
      orderId: json['orderId'] != null ? json['orderId'] as int : 0,
      productType: json['productType'] as String? ?? '',
      productId: json['productId'] != null ? json['productId'] as int : null,
      petId: json['petId'] != null ? json['petId'] as int : null,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'orderId': orderId,
      'productType': productType,
      'quantity': quantity,
      'price': price,
    };
    data['productId'] = productId;
    data['petId'] = petId;
    return data;
  }
}
