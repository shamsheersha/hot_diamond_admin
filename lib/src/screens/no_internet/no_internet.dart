import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/connectivity/connectivity_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/connectivity/connectivity_event.dart';
import 'package:hot_diamond_admin/src/controllers/connectivity/connectivity_state.dart';
import 'package:hot_diamond_admin/src/screens/main_screen.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) {
        if (state is ConnectivitySuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.signal_wifi_off,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please check your internet connection',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  context.read<ConnectivityBloc>().add(CheckConnectivity());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}