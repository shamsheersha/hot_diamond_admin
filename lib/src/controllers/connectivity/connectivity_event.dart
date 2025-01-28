import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

abstract class ConnectivityEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckConnectivity extends ConnectivityEvent {}
class ConnectivityChanged extends ConnectivityEvent {
  final ConnectivityResult result;
  ConnectivityChanged(this.result);

  @override
  List<Object> get props => [result];
}