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
      productId: json['productId'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      quantity: json['quantity'],
      supplyCategoryId: json['supplyCategoryId'],
      supplyCategory: SupplyCategory.fromJson(json['supplyCategory']),
      images: (json['images'] as List)
          .map((image) => ProductImage.fromJson(image))
          .toList(),
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
      'images': images.map((image) => image.toJson()).toList(),
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
      supplyCategoryId: json['supplyCategoryId'],
      name: json['name'],
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
      productImageId: json['productImageId'],
      productId: json['productId'],
      imageUrl: json['imageUrl'],
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
