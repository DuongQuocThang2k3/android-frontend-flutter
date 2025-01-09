class PetService {
  final int serviceId;
  final String name;
  final int price;
  final String description;
  final List<ServiceImage> images;

  PetService({
    required this.serviceId,
    required this.name,
    required this.price,
    required this.description,
    required this.images,
  });

  factory PetService.fromJson(Map<String, dynamic> json) {
    return PetService(
      serviceId: json['serviceId'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      images: (json['images'] as List)
          .map((image) => ServiceImage.fromJson(image))
          .toList(),
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

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(
      id: json['id'],
      url: json['url'],
      serviceId: json['serviceId'],
    );
  }
}
