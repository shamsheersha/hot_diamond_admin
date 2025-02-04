import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hot_diamond_admin/src/enum/checkout_types.dart';
import 'package:hot_diamond_admin/src/model/address_model/address_model.dart';
import 'package:hot_diamond_admin/src/model/cart_item_model/cart_item_model.dart';
import 'package:hot_diamond_admin/src/model/order_model/order_model.dart';
import 'package:hot_diamond_admin/src/services/notification_service/notification_service.dart';

class OrderServices {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<OrderModel> createOrder({
    required List<CartItem> items,
    required Address deliveryAddress,
    required double totalAmount,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      final userId = _auth.currentUser!.uid;
      final orderRef = _firestore.collection('orders').doc();

      final orderData = {
        'userId': userId,
        'items': items.map((item) => item.toMap()).toList(),
        'deliveryAddress': deliveryAddress.toMap(),
        'totalAmount': totalAmount,
        'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
        'status': OrderStatus.pending.toString().split('.').last,
        'paymentMethod': paymentMethod.toString().split('.').last,
      };

      await orderRef.set(orderData);

      // Fetch the created document to get the server timestamp
      final createdDoc = await orderRef.get();
      final createdData = createdDoc.data() as Map<String, dynamic>;

      return OrderModel.fromMap(createdData, orderRef.id);
    } catch (error) {
      throw Exception('Failed to create order: $error');
    }
  }

  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userId = _auth.currentUser!.uid;

      // Query with proper index usage
      final orderSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception(
                'Request timeout: Please check your internet connection'),
          );

      return orderSnapshot.docs
          .map((doc) => OrderModel.fromMap(
                Map<String, dynamic>.from(doc.data()),
                doc.id,
              ))
          .toList();
    } catch (error) {
      if (error is FirebaseException && error.code == 'failed-precondition') {
        throw Exception(
          'Database index not found. Please wait a few minutes for the index to be created and try again.',
        );
      }
      throw Exception('Failed to fetch orders: $error');
    }
  }

  Future<List<OrderModel>> fetchAllOrders() async {
    try {
      log('Attempting to fetch all orders');

      final orderSnapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      if (orderSnapshot.docs.isEmpty) {
        log('No orders found in Firestore');
        return []; // Return an empty list instead of throwing an error
      }

      final orders = orderSnapshot.docs
          .map((doc) {
            final data = doc.data();
            log('Order data: $data'); // More detailed logging

            try {
              return OrderModel.fromMap(
                Map<String, dynamic>.from(data),
                doc.id,
              );
            } catch (e) {
              log('Error parsing order: $e');
              return null;
            }
          })
          .whereType<OrderModel>() // Filter out any null values
          .toList();

      log('Processed orders length: ${orders.length}');
      return orders;
    } catch (error) {
      log('Error fetching orders: $error');
      return []; // Return an empty list instead of throwing an exception
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    try {
      // Update order status in Firestore
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus.toString(),
        'updatedAt': DateTime.now(),
      });

      // Fetch order details to get user ID
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      final userId = orderDoc.data()?['userId'];

      if (userId != null) {
        // Fetch user's FCM token
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final fcmToken = userDoc.data()?['notficationToken'];
        final userName = userDoc.data()?['name'] ?? 'Customer';

        if (fcmToken != null) {
          // Prepare notification body based on status
          String body;
          switch (newStatus) {
            case OrderStatus.confirmed:
              body =
                  "Hi $userName, Your order #$orderId has been confirmed. We're preparing your items!";
              break;
            case OrderStatus.processing:
              body =
                  "Hi $userName, Your order #$orderId is now being processed.";
              break;
            case OrderStatus.shipped:
              body =
                  "Hi $userName, Your order #$orderId has been shipped. Track your package now!";
              break;
            case OrderStatus.delivered:
              body =
                  "Hi $userName, Your order #$orderId has been delivered. Thank you for shopping with us!";
              break;
            case OrderStatus.cancelled:
              body =
                  "Hi $userName, Your order #$orderId has been cancelled. Please contact support for more details.";
              break;
            default:
              body = "Hi $userName, There's an update to your order #$orderId.";
          }

          // Send push notification
          final notificationService = NotificationService();
          await notificationService.pushNotifications(
            titile: '📦 Order Update Alert',
            body: body,
            token: fcmToken,
          );
        }
      }
    } catch (error) {
      throw Exception('Failed to update order status: $error');
    }
  }

  Future<List<OrderModel>> fetchOrdersByDate(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final orderSnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .orderBy('createdAt', descending: true)
          .get();
      if (orderSnapshot.docs.isEmpty) {
        return [];
      }

      final orders = orderSnapshot.docs
          .map((doc) {
            final data = doc.data();
            try {
              return OrderModel.fromMap(
                Map<String, dynamic>.from(data),
                doc.id,
              );
            } catch (e) {
              return null;
            }
          })
          .whereType<OrderModel>()
          .toList();
      return orders;
    } catch (error) {
      throw Exception('Failed to fetch orders: $error');
    }
  }
}
