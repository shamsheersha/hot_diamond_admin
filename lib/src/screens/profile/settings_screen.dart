import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_event.dart';
import 'package:hot_diamond_admin/src/screens/add_category/category_screen.dart';
import 'package:hot_diamond_admin/src/screens/login/login_screen.dart';
import 'package:hot_diamond_admin/src/screens/privacy_policy/privacy_policy.dart';
import 'package:hot_diamond_admin/src/screens/terms_and_conditions/terms_and_conditions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final bool isWeb = screenSize.width > 600;

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
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWeb ? 600 : screenSize.width,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: isWeb ? 80 : 60,
                    backgroundColor: Colors.grey.shade200,
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                      width: isWeb ? 180 : 140,
                      height: isWeb ? 160 : 120,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // User Information
                  Text(
                    'Hot Diamond User',
                    style: TextStyle(
                      fontSize: isWeb ? 24 : 20,
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
                        MaterialPageRoute(
                          builder: (context) => const CategoryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  
                  _buildActionButton(
                    context,
                    icon: Icons.security,
                    text: 'Privacy Policy',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  
                  _buildActionButton(
                    context,
                    icon: Icons.description,
                    text: 'Terms and Conditions',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AdminTermsAndConditionsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  _buildActionButton(
                    context,
                    icon: Icons.logout,
                    text: 'Sign Out',
                    onPressed: () => _showLogoutConfirmDialog(context),
                    isDestructive: true,
                  ),

                  // Version number
                  const SizedBox(height: 40),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    
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
        icon: Icon(
          icon,
          size: isWeb ? 24 : 20,
        ),
        label: Text(
          text,
          style: TextStyle(
            fontSize: isWeb ? 16 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: isDestructive ? Colors.white : Colors.black87,
          backgroundColor: isDestructive ? Colors.red : Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isWeb ? 15 : 12,
          ),
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

  void _showLogoutConfirmDialog(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: isWeb ? 16 : 14),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<LoginBloc>().add(LogoutEvent());
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                'Sign Out',
                style: TextStyle(fontSize: isWeb ? 16 : 14),
              ),
            ),
          ],
        );
      },
    );
  }
}