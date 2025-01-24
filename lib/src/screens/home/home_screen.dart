import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_event.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_state.dart';
import 'package:hot_diamond_admin/src/enum/checkout_types.dart';
import 'package:hot_diamond_admin/src/model/order_model/order_model.dart';
import 'package:hot_diamond_admin/src/screens/admin_order_screen/order_screen.dart';
import 'package:hot_diamond_admin/src/screens/home/confirmed_order_screen/confirmed_order_screen.dart';

class HomeScreen extends StatelessWidget {
 const HomeScreen({super.key});

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hot Diamond Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[100],
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black,
              ),
            ),
          )
        ],
      ),
      body: BlocBuilder<AdminOrderBloc, AdminOrderState>(
        builder: (context, state) {
          log('Current State: $state'); // Debug print

          if (state is AdminOrderInitial) {
            log('Dispatching FetchAllOrders'); // Debug print
            context.read<AdminOrderBloc>().add(FetchAllOrders());
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          if (state is AdminOrderLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          if (state is AdminOrderFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.error}'),
                  ElevatedButton(
                    onPressed: () => context.read<AdminOrderBloc>().add(FetchAllOrders()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AdminOrdersLoaded) {
  log('Orders loaded: ${state.orders.length}'); // Debug print

  final deliveredOrders = state.orders
      .where((order) => order.status == OrderStatus.delivered)
      .toList();
  final pendingOrders = state.orders
      .where((order) => order.status != OrderStatus.delivered)
      .toList();

  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildOrderCard(
              context: context,
              title: 'Delivered Orders',
              count: deliveredOrders.length,
              icon: Icons.local_shipping,
              color: Colors.green,
              onTap: () => _navigateToOrders(
                  context, OrderStatus.delivered, deliveredOrders),
            ),
            const SizedBox(width: 15),
            _buildOrderCard(
              context: context,
              title: 'Pending Orders',
              count: pendingOrders.length,
              icon: Icons.pending_outlined,
              color: Colors.orange,
              onTap: () => _navigateToOrders(
                  context, null, pendingOrders),
            ),
          ],
        ),
      ],
    ),
  );
}

          return const Center(child: Text('Unexpected state'));
        },
      ),
    );
  }

 Widget _buildOrderCard({
   required BuildContext context,
   required String title,
   required int count,
   required IconData icon,
   required Color color,
   required VoidCallback onTap,
 }) {
   final formattedCount = count < 10 ? '0$count' : count.toString();

   return Expanded(
     child: InkWell(
       onTap: onTap,
       child: Container(
         padding: const EdgeInsets.all(15),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(15),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.1),
               blurRadius: 10,
               offset: const Offset(0, 5),
             )
           ],
         ),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   formattedCount,
                   style: const TextStyle(
                     fontSize: 70,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 const SizedBox(height: 20),
                 Text(
                   title,
                   style: TextStyle(
                     fontSize: 17,
                     fontWeight: FontWeight.bold,
                     color: Colors.grey[800],
                   ),
                 ),
               ],
             ),
           ],
         ),
       ),
     ),
   );
 }

 void _navigateToOrders(
     BuildContext context, OrderStatus? status, List<OrderModel> orders) {
   if (status == OrderStatus.delivered) {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => ConfirmedOrdersScreen(orders: orders),
       ),
     );
   } else {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => OrdersScreen(
           initialStatus: status,
           preFilteredOrders: orders,
         ),
       ),
     );
   }
 }
}