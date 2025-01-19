import 'package:hot_diamond_admin/src/enum/discount_type.dart';

class OfferModel {
  final bool isEnabled;
  final DiscountType discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final String description;

  OfferModel({
    required this.isEnabled,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'discountType': discountType.name,
      'discountValue': discountValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
    };
  }

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
        isEnabled: map['isEnabled'] ?? false,
        discountType: DiscountType.values.firstWhere(
          (e) => e.name == map['discountType'],
          orElse: () => DiscountType.percentage,
        ),
        discountValue: (map['discountValue'] ?? 0.0).toDouble(),
        startDate: DateTime.parse(
            map['startDate'] ?? DateTime.now().toIso8601String()),
        endDate:
            DateTime.parse(map['endDate'] ?? DateTime.now().toIso8601String()),
        description: map['description'] ?? '');
  }
}
