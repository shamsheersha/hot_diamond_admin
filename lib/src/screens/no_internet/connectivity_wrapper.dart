import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/connectivity/connectivity_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/connectivity/connectivity_state.dart';
import 'package:hot_diamond_admin/src/screens/no_internet/no_internet.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  
  const ConnectivityWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) {
        if (state is ConnectivityFailure) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NoInternetScreen()),
          );
        }
      },
      builder: (context, state) {
        return child;
      },
    );
  }
}