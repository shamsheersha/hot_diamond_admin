import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hot_diamond_admin/src/controllers/connectivity/connectivity_event.dart';

import 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  ConnectivityBloc() : super(ConnectivityInitial()) {
    on<CheckConnectivity>(_onCheckConnectivity);
    on<ConnectivityChanged>(_onConnectivityChanged);

    // Initialize the connectivity stream
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      add(ConnectivityChanged(result));
    });
  }

  Future<void> _onCheckConnectivity(CheckConnectivity event, Emitter<ConnectivityState> emit) async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      emit(ConnectivityFailure());
    } else {
      emit(ConnectivitySuccess());
    }
  }

  void _onConnectivityChanged(ConnectivityChanged event, Emitter<ConnectivityState> emit) {
    if (event.result == ConnectivityResult.none) {
      emit(ConnectivityFailure());
    } else {
      emit(ConnectivitySuccess());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}