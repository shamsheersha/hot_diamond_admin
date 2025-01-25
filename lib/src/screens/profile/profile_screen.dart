// lib/src/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_event.dart';
import 'package:hot_diamond_admin/src/screens/add_category/category_screen.dart';
import 'package:hot_diamond_admin/src/screens/login/login_screen.dart';
import 'package:hot_diamond_admin/src/screens/privacy_policy/privacy_policy.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Main Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey.shade200,
                    child: Image.asset('assets/840ccc14-b0e1-4ec2-8b65-3332ab05c32b_page-0003.png',fit: BoxFit.cover,width: 180,height:160,)
                  ),
                  const SizedBox(height: 30),

                  // User Information
                  const Text(
                    'Hot Diamond User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // Action Buttons
                  _buildActionButton(
                    context,
                    icon: Icons.category,
                    text: 'Manage Categories',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const CategoryScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 10,),
                  //Privacy Policy
                  _buildActionButton(context, icon: Icons.security, text: 'Privacy Policy', onPressed: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                      );
                  }),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    context,
                    icon: Icons.logout,
                    text: 'Sign Out',
                    onPressed: () => _showLogoutConfirmDialog(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
          
          // Version Number at Bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logout Confirmation Dialog
  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Perform logout
                context.read<LoginBloc>().add(LogoutEvent());
                
                // Navigate to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  // Custom Action Button Widget
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: isDestructive ? Colors.white : Colors.black87,
          backgroundColor: isDestructive ? Colors.red : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          side: BorderSide(
            color: isDestructive ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}