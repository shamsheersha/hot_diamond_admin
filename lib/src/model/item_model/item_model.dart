class ItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String imageUrl;

  ItemModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.categoryId,
      required this.price,
      required this.imageUrl});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrl
    };
  }

   // Adding the copyWith method
  ItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    String? imageUrl,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory ItemModel.fromMap(Map<String, dynamic> map, String id) {
    return ItemModel(
        id: id,
        name: map['name'],
        description: map['description'],
        categoryId: map['categoryId'],
        price: map['price'],
        imageUrl: map['imageUrl']);
  }
}
