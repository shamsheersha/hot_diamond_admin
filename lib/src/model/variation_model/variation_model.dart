import 'package:hot_diamond_admin/src/enum/portion_type.dart';

class VariationModel {
  final String id;
  final int quantity;  
  final PortionType portionType;  
  final double price;

  VariationModel({
    required this.id,
    required this.quantity,
    required this.portionType,
    required this.price,
  });

  String get displayName => '$quantity ${portionType.name}'; 

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantity': quantity,
      'portionType': portionType.name,
      'price': price,
    };
  }

  factory VariationModel.fromMap(Map<String, dynamic> map) {
    return VariationModel(
      id: map['id'] ?? '',
      quantity: map['quantity'] ?? 0,
      portionType: PortionType.values.firstWhere(
        (e) => e.name == map['portionType'],
        orElse: () => PortionType.pieces,
      ),
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }
}