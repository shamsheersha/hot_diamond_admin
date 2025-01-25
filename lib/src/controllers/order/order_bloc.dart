import 'package:bloc/bloc.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_event.dart';
import 'package:hot_diamond_admin/src/controllers/order/order_state.dart';
import 'package:hot_diamond_admin/src/services/order_service/order_service.dart';


class AdminOrderBloc extends Bloc<AdminOrderEvent, AdminOrderState> {
  final OrderServices _orderServices;

  AdminOrderBloc(this._orderServices) : super(AdminOrderInitial()) {
    on<FetchAllOrders>(_onFetchAllOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<FetchOrdersByDate>(onFetchOrdersByDate);
  }

  Future<void> _onFetchAllOrders(
    FetchAllOrders event,
    Emitter<AdminOrderState> emit,
  ) async {
    emit(AdminOrderLoading());
    try {
      final orders = await _orderServices.fetchAllOrders();
      emit(AdminOrdersLoaded(orders));
    } catch (error) {
      emit(AdminOrderFailure(error.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<AdminOrderState> emit,
  ) async {
    try {
      await _orderServices.updateOrderStatus(
        orderId: event.orderId,
        newStatus: event.newStatus,
      );
      add(FetchAllOrders()); // Refresh orders after update
    } catch (error) {
      emit(AdminOrderFailure(error.toString()));
    }
  }


  Future onFetchOrdersByDate(
    FetchOrdersByDate event,Emitter<AdminOrderState> emit,
  )async{
    emit(AdminOrderLoading());
    try {
      final orders = await _orderServices.fetchOrdersByDate(event.startDate, event.endDate);
      emit(AdminOrdersLoaded(orders));
    } catch (error) {
      emit(AdminOrderFailure(error.toString()));
    }
  }
}
