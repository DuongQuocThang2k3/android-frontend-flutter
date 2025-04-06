class CartItem {
  final String productType; // "Pet" hoặc "Product"
  final int productId;
  final String name;
  final double unitPrice;
  int quantity;
  final String imageUrl;

  CartItem({
    required this.productType,
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.imageUrl,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'productType': productType,
        'productId': productId,
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'imageUrl': imageUrl,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productType: json['productType'],
        productId: json['productId'],
        name: json['name'],
        unitPrice: (json['unitPrice'] as num).toDouble(),
        quantity: json['quantity'],
        imageUrl: json['imageUrl'],
      );
}