class ItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
   List<String> imageUrls;

  // Getter for the main image
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.price,
    this.imageUrls = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrls': imageUrls,
    };
  }

  ItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    List<String>? imageUrls,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  factory ItemModel.fromMap(Map<String, dynamic> map, String id) {
    return ItemModel(
      id: id,
      name: map['name'],
      description: map['description'],
      categoryId: map['categoryId'],
      price: map['price'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }
}
