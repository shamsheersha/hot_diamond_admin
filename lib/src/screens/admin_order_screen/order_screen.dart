import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_event.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_state.dart';
import 'package:hot_diamond_admin/src/enum/checkout_types.dart';
import 'package:hot_diamond_admin/src/model/cart_item_model/cart_item_model.dart';
import 'package:hot_diamond_admin/src/model/order_model/order_model.dart';

import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  final OrderStatus? initialStatus;
  final List<OrderModel>? preFilteredOrders;
  const OrdersScreen({super.key, this.initialStatus, this.preFilteredOrders});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'All',
    'Pending',
    'Processing',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<AdminOrderBloc>().add(FetchAllOrders());
    if (widget.initialStatus != null) {
      final initialIndex = _tabs.indexWhere((tab) =>
          tab.toLowerCase() ==
          widget.initialStatus.toString().split('.').last.toLowerCase());
      if (initialIndex != -1) {
        _tabController.index = initialIndex;
      }
    }

    if (widget.preFilteredOrders == null) {
      context.read<AdminOrderBloc>().add(FetchAllOrders());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          labelColor: Colors.red[700],
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.red[700],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          context.read<AdminOrderBloc>().add(FetchAllOrders());
          return Future.delayed(const Duration(seconds: 2)); // Simulate loading
        },
        color: Colors.black,
        child: BlocBuilder<AdminOrderBloc, AdminOrderState>(
          builder: (context, state) {
            if (state is AdminOrderLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.black));
            }

            if (state is AdminOrdersLoaded) {
              if (state.orders.isEmpty) {
                return const Center(child: Text('No orders found'));
              }

              return TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  final filteredOrders = _filterOrders(state.orders, tab);
                  return _buildOrdersList(filteredOrders);
                }).toList(),
              );
            }

            if (state is AdminOrderFailure) {
              return Center(child: Text('Error: ${state.error}'));
            }

            return const Center(child: Text('No orders found'));
          },
        ),
      ),
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders, String tab) {
    if (tab == 'All') return orders;
    return orders
        .where((order) =>
            order.status.toString().split('.').last.toLowerCase() ==
            tab.toLowerCase())
        .toList();
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    // Safely get the first 8 characters of the ID, or use full ID if shorter
    final displayId =
        order.id.length >= 8 ? order.id.substring(0, 8) : order.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Column(
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
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(order.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.length} items',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildSectionTitle('Items'),
                ...order.items.map((item) => _buildOrderItem(item)),
                const Divider(height: 32),
                _buildSectionTitle('Delivery Address'),
                _buildAddressInfo(order),
                const Divider(height: 32),
                _buildPaymentInfo(order),
                const Divider(height: 32),
                _buildUpdateStatusDropdown(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    final colors = {
      OrderStatus.pending: Colors.orange,
      OrderStatus.confirmed: Colors.blue[300],
      OrderStatus.processing: Colors.blue,
      OrderStatus.shipped: Colors.amber,
      OrderStatus.delivered: Colors.green,
      OrderStatus.cancelled: Colors.red,
    };

    final color =
        colors[status] ?? Colors.grey; // Fallback color if status not found

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toString().split('.').last,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.item.imageUrls.isNotEmpty
                  ? item.item.imageUrls.first
                  : 'placeholder_url',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.item.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (item.selectedVariation != null)
                  Text(
                    item.selectedVariation!.displayName,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.totalPrice.toStringAsFixed(2)} (${item.quantity} items)',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfo(OrderModel order) {
    final address = order.deliveryAddress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(address.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('${address.houseNumber}, ${address.roadName}'),
        Text('${address.city}, ${address.state} - ${address.pincode}'),
        const SizedBox(height: 4),
        Text('Phone: ${address.phoneNumber}'),
      ],
    );
  }

  Widget _buildPaymentInfo(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              order.paymentMethod.toString().split('.').last.toUpperCase(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Total Amount',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpdateStatusDropdown(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Update Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButton<OrderStatus>(
          value: order.status,
          onChanged: (newStatus) {
            if (newStatus != null) {
              context
                  .read<AdminOrderBloc>()
                  .add(UpdateOrderStatus(order.id, newStatus));
            }
          },
          items: OrderStatus.values.map((status) {
            return DropdownMenuItem<OrderStatus>(
              value: status,
              child: Text(status.toString().split('.').last),
            );
          }).toList(),
        ),
      ],
    );
  }
}
