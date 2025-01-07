class productPost {
  productPost({
    this.id, // Không còn required
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  final int? id; // id là nullable vì server tự tạo
  final String? name;
  final double? price;
  final String? image;
  final String? description;

  factory productPost.fromJson(Map<String, dynamic> json) {
    return productPost(
      id: json["id"] as int?,  // Kiểm tra id có thể là null
      name: json["name"] ?? "Unknown",  // Default value nếu tên null
      price: (json["price"] as num?)?.toDouble(), // Chuyển đổi về double
      image: json["image"] ?? "",  // Default giá trị mặc định nếu image null
      description: json["description"] ?? "",  // Default nếu mô tả null
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, // Giữ nguyên ID cho trường hợp update, hoặc null khi tạo mới
    "name": name ?? "",  // Nếu name null, cung cấp giá trị mặc định
    "price": price ?? 0.0,  // Nếu price null, cung cấp giá trị mặc định
    "image": image ?? "",  // Nếu image null, cung cấp giá trị mặc định
    "description": description ?? "",  // Nếu description null, cung cấp giá trị mặc định
  };
}