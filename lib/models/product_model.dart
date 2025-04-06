class Product {
  final int productId;
  final String name;
  final double price;
  final String description;
  final int quantity;
  final int supplyCategoryId;
  final SupplyCategory supplyCategory;
  final List<ProductImage> images;

  Product({
    required this.productId,
    required this.name,
    required this.price,
    required this.description,
    required this.quantity,
    required this.supplyCategoryId,
    required this.supplyCategory,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      supplyCategoryId: json['supplyCategoryId'] as int? ?? 0,
      supplyCategory: SupplyCategory.fromJson(
          json['supplyCategory'] as Map<String, dynamic>? ?? {}),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'description': description,
      'quantity': quantity,
      'supplyCategoryId': supplyCategoryId,
      'supplyCategory': supplyCategory.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
    };
  }
}

class SupplyCategory {
  final int supplyCategoryId;
  final String name;

  SupplyCategory({
    required this.supplyCategoryId,
    required this.name,
  });

  factory SupplyCategory.fromJson(Map<String, dynamic> json) {
    return SupplyCategory(
      supplyCategoryId: json['supplyCategoryId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplyCategoryId': supplyCategoryId,
      'name': name,
    };
  }
}

class ProductImage {
  final int productImageId;
  final int productId;
  final String imageUrl;

  ProductImage({
    required this.productImageId,
    required this.productId,
    required this.imageUrl,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      productImageId: json['productImageId'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productImageId': productImageId,
      'productId': productId,
      'imageUrl': imageUrl,
    };
  }
}
