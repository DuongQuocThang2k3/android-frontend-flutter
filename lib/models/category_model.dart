class Category {
  final String id;
  final String image;
  final String name;

  Category({
    required this.id,
    required this.name,
    required this.image,
  });
}

final categories = [
  Category(id: "0",name: "Today Deals", image: "assets/today_deals_category.png"),
  Category(id: "1",name: "Thức ăn cho pet", image: "assets/cat_food_category.png"),
  Category(id: "2",name: "Đồ chơi cho pet", image: "assets/cat_toy_category.png"),
  Category(id: "3",name: "Chăm sóc & vệ sinh", image: "assets/pet_category02.png"),
  Category(id: "4",name: "Làm đẹp & sức khỏe", image: "assets/pet_category03.png"),
  Category(id: "5",name: "Vận chuyển", image: "assets/pet_category04.png"),
];
