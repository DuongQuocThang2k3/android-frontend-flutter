class Pet {
  final String image;
  final String name;

  Pet({
    required this.name,
    required this.image,
  });
}

final pets = [
  Pet(name: "Chim", image: "assets/bird_pet.jpg"),
  Pet(name: "Mèo", image: "assets/cat_pet.jpg"),
  Pet(name: "Chó", image: "assets/dog_pet.jpg"),
  Pet(name: "Cá", image: "assets/fish_pet.jpg"),
  Pet(name: "Hamster", image: "assets/hamster_pet.jpg"),
];
