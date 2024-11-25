import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_event.dart';
import 'package:hot_diamond_admin/src/screens/login/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hot Diamond Admin'),
        backgroundColor: Colors.white,
        // leading: Icon(Icons.list),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              child:const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black,
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            context.read<LoginBloc>().add(LogoutEvent());

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}
