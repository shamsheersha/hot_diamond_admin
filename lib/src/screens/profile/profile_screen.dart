import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_event.dart';
import 'package:hot_diamond_admin/src/screens/add_category/category_screen.dart';
import 'package:hot_diamond_admin/src/screens/login/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                context.read<LoginBloc>().add(LogoutEvent());

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Sign Out'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CategoryScreen()));
                },
                child: Text('Category')),
          ],
        ),
      ),
    );
  }
}
