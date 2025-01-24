import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hot_diamond_admin/src/enum/checkout_types.dart';
import 'package:hot_diamond_admin/src/model/address_model/address_model.dart';
import 'package:hot_diamond_admin/src/model/cart_item_model/cart_item_model.dart';


class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final Address deliveryAddress;
  final double totalAmount;
  final DateTime createdAt;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    required this.totalAmount,
    required this.createdAt,
    required this.status,
    required this.paymentMethod,
    this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      deliveryAddress: Address.fromMap(
          map['deliveryAddress'] as Map<String, dynamic>, map['addressId'] ?? ''),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status'] ?? 'pending'}',
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${map['paymentMethod'] ?? 'cod'}',
      ),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'deliveryAddress': deliveryAddress.toMap(),
      'totalAmount': totalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    Address? deliveryAddress,
    double? totalAmount,
    DateTime? createdAt,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
