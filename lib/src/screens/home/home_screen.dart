// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hot_diamond_admin/src/controllers/order/order_bloc.dart';
// import 'package:hot_diamond_admin/src/controllers/order/order_event.dart';
// import 'package:hot_diamond_admin/src/controllers/order/order_state.dart';
// import 'package:hot_diamond_admin/src/enum/checkout_types.dart';
// import 'package:hot_diamond_admin/src/model/order_model/order_model.dart';
// import 'package:hot_diamond_admin/src/screens/order_screen/order_screen.dart';
// import 'package:hot_diamond_admin/src/screens/home/confirmed_order_screen/confirmed_order_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Hot Diamond Admin',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.grey[100],
//       ),
//       body: BlocBuilder<AdminOrderBloc, AdminOrderState>(
//         builder: (context, state) {
//           log('Current State: $state'); // Debug print

//           if (state is AdminOrderInitial) {
//             log('Dispatching FetchAllOrders'); // Debug print
//             context.read<AdminOrderBloc>().add(FetchAllOrders());
//             return const Center(
//                 child: CircularProgressIndicator(color: Colors.black));
//           }

//           if (state is AdminOrderLoading) {
//             return const Center(
//                 child: CircularProgressIndicator(color: Colors.black));
//           }

//           if (state is AdminOrderFailure) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Error: ${state.error}'),
//                   ElevatedButton(
//                     onPressed: () =>
//                         context.read<AdminOrderBloc>().add(FetchAllOrders()),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (state is AdminOrdersLoaded) {
//             log('Orders loaded: ${state.orders.length}'); // Debug print

//             final deliveredOrders = state.orders
//                 .where((order) => order.status == OrderStatus.delivered)
//                 .toList();
//             final pendingOrders = state.orders
//                 .where((order) => order.status != OrderStatus.delivered)
//                 .toList();

//             return Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Order Overview',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       _buildOrderCard(
//                         context: context,
//                         title: 'Delivered Orders',
//                         count: deliveredOrders.length,
//                         icon: Icons.local_shipping,
//                         color: Colors.green,
//                         onTap: () => _navigateToOrders(
//                             context, OrderStatus.delivered, deliveredOrders),
//                       ),
//                       const SizedBox(width: 15),
//                       _buildOrderCard(
//                         context: context,
//                         title: 'Pending Orders',
//                         count: pendingOrders.length,
//                         icon: Icons.pending_outlined,
//                         color: Colors.orange,
//                         onTap: () =>
//                             _navigateToOrders(context, null, pendingOrders),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           }

//           return const Center(child: Text('Unexpected state'));
//         },
//       ),
//     );
//   }

//   Widget _buildOrderCard({
//     required BuildContext context,
//     required String title,
//     required int count,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     final formattedCount = count < 10 ? '0$count' : count.toString();

//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(15),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               )
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     formattedCount,
//                     style: const TextStyle(
//                       fontSize: 70,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateToOrders(
//       BuildContext context, OrderStatus? status, List<OrderModel> orders) {
//     if (status == OrderStatus.delivered) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ConfirmedOrdersScreen(orders: orders),
//         ),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OrdersScreen(
//             initialStatus: status,
//             preFilteredOrders: orders,
//           ),
//         ),
//       );
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_event.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_state.dart';
import 'package:hot_diamond_admin/src/enum/checkout_types.dart';
import 'package:hot_diamond_admin/src/model/order_model/order_model.dart';
import 'package:hot_diamond_admin/src/screens/order_screen/order_screen.dart';
import 'package:hot_diamond_admin/src/screens/home/confirmed_order_screen/confirmed_order_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hot Diamond Admin',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[100],
      ),
      body: BlocBuilder<AdminOrderBloc, AdminOrderState>(
        builder: (context, state) {
          if (state is AdminOrderInitial) {
            context.read<AdminOrderBloc>().add(FetchAllOrders());
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }

          if (state is AdminOrderLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }

          if (state is AdminOrderFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.error}'),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AdminOrderBloc>().add(FetchAllOrders()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AdminOrdersLoaded) {
            final deliveredOrders = state.orders
                .where((order) => order.status == OrderStatus.delivered)
                .toList();
            final pendingOrders = state.orders
                .where((order) => order.status != OrderStatus.delivered)
                .toList();

            final totalRevenue =
                state.orders.fold(0.0, (sum, order) => sum + order.totalAmount);

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
                        onTap: () =>
                            _navigateToOrders(context, null, pendingOrders),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTotalRevenueCard(totalRevenue),
                  const SizedBox(height: 20),
                  _buildDateFilter(context),
                  const SizedBox(height: 20),
                  _buildSalesGraph(state.orders),
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

  Widget _buildTotalRevenueCard(double totalRevenue) {
    return Container(
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
        children: [
          const Text(
            'Total Revenue',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '₹${totalRevenue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
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

  Widget _buildDateFilter(BuildContext context) {
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: startDateController,
            decoration: const InputDecoration(
              labelText: 'Start Date',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              labelStyle: TextStyle(color: Colors.black),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.red, // Custom primary color
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                startDateController.text =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
              }
            },
            readOnly: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: endDateController,
            decoration: const InputDecoration(
              labelText: 'End Date',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              labelStyle: TextStyle(color: Colors.black),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.red, // Custom primary color
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                endDateController.text =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
              }
            },
            readOnly: true,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            final startDate =
                DateFormat('yyyy-MM-dd').parse(startDateController.text);
            final endDate =
                DateFormat('yyyy-MM-dd').parse(endDateController.text);
            context
                .read<AdminOrderBloc>()
                .add(FetchOrdersByDate(startDate, endDate));
          },
        ),
      ],
    );
  }

  Widget _buildSalesGraph(List<OrderModel> orders) {
    final salesData = _generateSalesData(orders);

    return Expanded(
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                // getTextStyles: (value, meta) {
                //   const style = TextStyle(
                //     color: Color(0xff68737d),
                //     fontWeight: FontWeight.bold,
                //     fontSize: 16,
                //   );
                //   return style;
                // },
                getTitlesWidget: (value, meta) {
                  return Text(
                    DateFormat.M().format(DateTime(1970, value.toInt())),
                    style: const TextStyle(
                      color: Color(0xff68737d),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                // getTextStyles: (value, meta) {
                //   const style = TextStyle(
                //     color: Color(0xff67727d),
                //     fontWeight: FontWeight.bold,
                //     fontSize: 15,
                //   );
                //   return style;
                // },
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₹${value.toInt()}',
                    style: const TextStyle(
                      color: Color(0xff67727d),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: salesData,
              isCurved: true,
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xffFF0000)
                        .withOpacity(0.3), // Red with opacity
                    const Color(0xffFF0000)
                        .withOpacity(0.1), // Red with opacity
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              gradient: LinearGradient(
                colors: [
                  const Color(0xffFF0000), // Red
                  const Color(0xffFF0000).withOpacity(0.5), // Red with opacity
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSalesData(List<OrderModel> orders) {
    final salesData = <FlSpot>[];
    final Map<String, double> dailySales = {};

    for (var order in orders) {
      final date = DateFormat('yyyy-MM-dd').format(order.createdAt);
      if (dailySales.containsKey(date)) {
        dailySales[date] = dailySales[date]! + order.totalAmount;
      } else {
        dailySales[date] = order.totalAmount;
      }
    }

    final sortedDates = dailySales.keys.toList()..sort();
    for (var date in sortedDates) {
      final spot =
          FlSpot(sortedDates.indexOf(date).toDouble(), dailySales[date]!);
      salesData.add(spot);
    }

    return salesData;
  }
}
