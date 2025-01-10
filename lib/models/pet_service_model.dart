class PetService {
  final int serviceId; // Thêm serviceId
  final String name;
  final double price;
  final String description;
  final List<ServiceImage> images;

  PetService({
    required this.serviceId,
    required this.name,
    required this.price,
    required this.description,
    required this.images,
  });

  // Factory từ JSON
  factory PetService.fromJson(Map<String, dynamic> json) {
    return PetService(
      serviceId: json['serviceId'] ?? 0, // Gán giá trị mặc định nếu null
      name: json['name'] ?? '',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] ?? 0.0),
      description: json['description'] ?? 'Không có mô tả',
      images: (json['images'] as List<dynamic>?)
          ?.map((imageJson) => ServiceImage.fromJson(imageJson))
          .toList() ??
          [],
    );
  }
}

class ServiceImage {
  final int id;
  final String url;
  final int serviceId;

  ServiceImage({
    required this.id,
    required this.url,
    required this.serviceId,
  });

  // Factory từ JSON
  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      serviceId: json['serviceId'] ?? 0,
    );
  }
}
