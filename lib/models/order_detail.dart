class OrderDetail {
  int id;
  int orderId;
  String productType;
  int? productId;
  int? petId;
  int quantity;
  double price;

  OrderDetail({
    this.id = 0,
    this.orderId = 0,
    required this.productType,
    this.productId,
    this.petId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'productType': productType,
        'productId': productId,
        'petId': petId,
        'quantity': quantity,
        'price': price,
      };
}