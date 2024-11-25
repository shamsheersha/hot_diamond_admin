import 'package:flutter/material.dart';
import 'package:hot_diamond_admin/src/screens/category/category_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: TextButton(onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=> CategoryScreen()));}, child: Text('Category')),),
    );
  }
}