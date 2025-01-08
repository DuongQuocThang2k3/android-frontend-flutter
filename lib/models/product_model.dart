class ProductModel {
  final String image;
  final String brand;
  final String name;
  final String rating;
  final String price;

  const ProductModel({
    required this.image,
    required this.brand,
    required this.name,
    required this.rating,
    required this.price,
  });
}

const products = [
  ProductModel(
    image: "assets/img_cat_dog_bed.jpg",
    brand: "Frisco",
    name: "Giường vuông cho mèo & chó, màu nâu, cỡ lớn",
    rating: "4.5",
    price: "45.000 VND",
  ),
  ProductModel(
    image: "assets/img_cat_condo.jpg",
    brand: "Frisco",
    name: "Cây và nhà cho mèo, cao 52 inch, màu nâu",
    rating: "4.5",
    price: "125.000 VND",
  ),
  ProductModel(
    image: "assets/img_dog_toy.jpg",
    brand: "Frisco",
    name: "Đồ chơi hình shamrock phát tiếng kêu, 3 món",
    rating: "4.5",
    price: "70.000 VND",
  ),
  ProductModel(
    image: "assets/img_dog_bowl.jpg",
    brand: "Frisco",
    name: "Bát silicone gấp gọn cho chó & mèo, màu xám, 3 cốc",
    rating: "4.5",
    price: "37.000 VND",
  )
];
