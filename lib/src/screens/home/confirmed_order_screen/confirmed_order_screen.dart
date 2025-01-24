import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_event.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_state.dart';
import 'package:hot_diamond_admin/src/enum/checkout_types.dart';
import 'package:hot_diamond_admin/src/model/address_model/address_model.dart';
import 'package:hot_diamond_admin/src/model/cart_item_model/cart_item_model.dart';
import 'package:hot_diamond_admin/src/model/order_model/order_model.dart';
import 'package:intl/intl.dart';

class ConfirmedOrdersScreen extends StatelessWidget {
  final List<OrderModel> orders;

  const ConfirmedOrdersScreen({
    super.key,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivered Orders',style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.grey[100],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          context.read<AdminOrderBloc>().add(FetchAllOrders());
          return Future<void>.value();
        },
        color: Colors.black,
        child: BlocBuilder<AdminOrderBloc, AdminOrderState>(
          builder: (context, state) {
            if (state is AdminOrderLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.black));
            }

            if (state is AdminOrdersLoaded) {
              final deliveredOrders = state.orders
                  .where((order) => order.status == OrderStatus.delivered)
                  .toList();

              if (deliveredOrders.isEmpty) {
                return const Center(child: Text('No delivered orders found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: deliveredOrders.length,
                itemBuilder: (context, index) => _buildOrderCard(deliveredOrders[index]),
              );
            }

            return const Center(child: Text('No orders found'));
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final displayId = order.id.length >= 8 ? order.id.substring(0, 8) : order.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #$displayId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM dd, yyyy').format(order.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const Divider(height: 24),
            _buildOrderItems(order.items),
            const Divider(height: 24),
            _buildOrderTotal(order.totalAmount),
            const SizedBox(height: 16),
            _buildCustomerInfo(order.deliveryAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: const Text(
        'Delivered',
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOrderItems(List<CartItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.item.name,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                '${item.quantity}x ₹${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildOrderTotal(double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Amount',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          '₹${total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(Address address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Address',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Text(address.name),
        Text('${address.houseNumber}, ${address.roadName}'),
        Text('${address.city}, ${address.state} - ${address.pincode}'),
        const SizedBox(height: 4),
        Text('Phone: ${address.phoneNumber}'),
      ],
    );
  }
}
