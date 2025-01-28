import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hot_diamond_admin/src/screens/main_screen.dart';
import 'package:hot_diamond_admin/src/screens/no_internet/no_internet.dart';

class ConnectivityChecker extends StatelessWidget {
  const ConnectivityChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        return FutureBuilder<ConnectivityResult>(
          future: Connectivity().checkConnectivity(),
          builder: (context, futureSnapshot) {
            final data = snapshot.data ?? futureSnapshot.data;
            
            if (data == ConnectivityResult.none) {
              return const NoInternetScreen();
            }
            
            return const MainScreen();
          },
        );
      },
    );
  }
}