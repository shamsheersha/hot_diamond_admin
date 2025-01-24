
import 'package:equatable/equatable.dart';
import 'package:hot_diamond_admin/src/enum/checkout_types.dart';

abstract class AdminOrderEvent extends Equatable {
  const AdminOrderEvent();

  @override
  List<Object> get props => [];
}

class FetchAllOrders extends AdminOrderEvent {}

class UpdateOrderStatus extends AdminOrderEvent {
  final String orderId;
  final OrderStatus newStatus;

  const UpdateOrderStatus(this.orderId, this.newStatus);

  @override
  List<Object> get props => [orderId, newStatus];
}
