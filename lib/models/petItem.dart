class PetItem {
  final int petId;
  final String name;
  final int age;
  final double price;
  final String description;
  final int categoryId;
  final List<String> images;
  final String status;

  PetItem({
    required this.petId,
    required this.name,
    required this.age,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.images,
    required this.status,
  });

  factory PetItem.fromJson(Map<String, dynamic> json) {
    // JSON có thể trả về price là int, double, hoặc string
    final rawPrice = json['price'];
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;

    return PetItem(
      petId: json['petId'] as int,
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      price: price,
      description: json['description'] as String? ?? '',
      categoryId: json['categoryId'] as int? ?? 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e['url'] as String)
              .toList() ??
          [],
      status: json['status'] as String? ?? '',
    );
  }

  /// Serialize thành JSON để gửi lên API.
  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'name': name,
      'age': age,
      'price': price,
      'description': description,
      'categoryId': categoryId,
      'status': status,
      'images': images
          .map((url) => {
                'petId': petId,
                'url': url,
              })
          .toList(),
    };
  }

  /// Tạo bản copy với một vài trường được override
  PetItem copyWith({
    int? petId,
    String? name,
    int? age,
    double? price,
    String? description,
    int? categoryId,
    List<String>? images,
    String? status,
  }) {
    return PetItem(
      petId: petId ?? this.petId,
      name: name ?? this.name,
      age: age ?? this.age,
      price: price ?? this.price,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      images: images ?? this.images,
      status: status ?? this.status,
    );
  }
}
