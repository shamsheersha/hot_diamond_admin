import 'package:hot_diamond_admin/src/enum/discount_type.dart';
import 'package:hot_diamond_admin/src/model/offer_model/offer_model.dart';
import 'package:hot_diamond_admin/src/model/variation_model/variation_model.dart';

class ItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  List<String> imageUrls;
  List<VariationModel> variations;
  final OfferModel? offer;
  final bool isInStock;

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
    this.offer,
    this.isInStock = true
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrls': imageUrls,
      'variations': variations.map((v) => v.toMap()).toList(),
      'offer': offer?.toMap(),
      'isInStock' : isInStock
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
    OfferModel? offer,
    bool? isInStock,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrls: imageUrls ?? this.imageUrls,
      variations: variations ?? this.variations,
      offer: offer,
      isInStock: isInStock ?? this.isInStock,
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
      offer: map['offer'] != null ? OfferModel.fromMap(map['offer']) : null,
      isInStock: map['isInStock'] ?? true,
    );
  }

  // Add helper methods for offer calculations
  bool get hasValidOffer {
    if (offer == null || !offer!.isEnabled) return false;
    final now = DateTime.now();
    return now.isAfter(offer!.startDate) && now.isBefore(offer!.endDate);
  }

  double calculateDiscountedPrice(double originalPrice) {
    if (!hasValidOffer) return originalPrice;
    
    if (offer!.discountType == DiscountType.percentage) {
      return originalPrice - (originalPrice * (offer!.discountValue / 100));
    } else {
      return originalPrice - offer!.discountValue;
    }
  }

  double get finalPrice {
    double basePrice = price;
    if (variations.isNotEmpty) {
      basePrice = variations.map((v) => v.price).reduce((a, b) => a < b ? a : b);
    }
    return hasValidOffer ? calculateDiscountedPrice(basePrice) : basePrice;
  }
}
