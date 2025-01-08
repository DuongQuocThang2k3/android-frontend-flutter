class Category {
  final String image;
  final String name;

  Category({
    required this.name,
    required this.image,
  });
}

final categories = [
  Category(name: "Today Deals", image: "assets/today_deals_category.png"),
  Category(name: "Thức ăn cho pet", image: "assets/cat_food_category.png"),
  Category(name: "Đồ chơi cho pet", image: "assets/cat_toy_category.png"),
  Category(name: "Chăm sóc & vệ sinh", image: "assets/pet_category02.png"),
  Category(name: "Làm đẹp & sức khỏe", image: "assets/pet_category03.png"),
  Category(name: "Vận chuyển", image: "assets/pet_category04.png"),
];
