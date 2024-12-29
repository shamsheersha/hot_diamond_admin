import 'package:hot_diamond_admin/src/model/variation_model/variation_model.dart';

class ItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  List<String> imageUrls;
  List<VariationModel> variations;

  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
  double get basePrice => variations.isNotEmpty ? variations.first.price : 0.0;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.price,
    this.imageUrls = const [],
    this.variations = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrls': imageUrls,
      'variations': variations.map((v) => v.toMap()).toList(),
    };
  }

  ItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    List<String>? imageUrls,
    bool? hasVariations,
    List<VariationModel>? variations,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrls: imageUrls ?? this.imageUrls,
      variations: variations ?? this.variations,
    );
  }

  factory ItemModel.fromMap(Map<String, dynamic> map, String id) {
    return ItemModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      variations: (map['variations'] as List<dynamic>?)
          ?.map((v) => VariationModel.fromMap(v))
          .toList() ?? [],
    );
  }
}