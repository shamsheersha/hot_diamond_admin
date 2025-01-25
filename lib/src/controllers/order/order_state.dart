
import 'package:equatable/equatable.dart';
import 'package:hot_diamond_admin/src/model/order_model/order_model.dart';

abstract class AdminOrderState extends Equatable {
  const AdminOrderState();

  @override
  List<Object> get props => [];
}

class AdminOrderInitial extends AdminOrderState {}

class AdminOrderLoading extends AdminOrderState {}

class AdminOrdersLoaded extends AdminOrderState {
  final List<OrderModel> orders;

  const AdminOrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

class AdminOrderFailure extends AdminOrderState {
  final String error;

  AdminOrderFailure(this.error);

  @override
  List<Object> get props => [error];
}
