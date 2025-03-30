class ProductPost {
  ProductPost({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  final int? id;
  final String? name;
  final int? price;
  final String? image;
  final String? description;

  factory ProductPost.fromJson(Map<String, dynamic> json) {
    return ProductPost(
      id: json["id"],
      name: json["name"],
      price: json["price"],
      image: json["image"],
      description: json["description"],
    );
  }
}
