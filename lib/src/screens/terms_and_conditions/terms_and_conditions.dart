
import 'package:flutter/material.dart';
import 'package:hot_diamond_admin/src/screens/login/widgets/custom_button_widget.dart';

class AdminTermsAndConditionsScreen extends StatelessWidget {
  const AdminTermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Terms and Conditions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'By accessing and using the admin panel of the Hot Diamond app, you agree to the following terms and conditions. Please read them carefully before proceeding.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('1. Account Responsibility'),
            const Text(
              'As an admin, you are responsible for maintaining the confidentiality of your login credentials. You are solely responsible for all actions performed through your account.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('2. Data Management'),
            const Text(
              '- You are authorized to add, edit, and delete categories, items, and orders within the app.\n'
              '- Ensure the accuracy of data while adding or updating items, including prices and descriptions.\n'
              '- Mismanagement or inaccurate data entry may result in operational issues.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('3. User Management'),
            const Text(
              '- Admins have access to view and manage user profiles, including account deletions when required.\n'
              '- Ensure that user data is handled securely and in compliance with applicable privacy laws.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('4. Order Processing'),
            const Text(
              '- Admins are responsible for managing and processing customer orders promptly.\n'
              '- Ensure that all orders are accurate and reflect the inventory available.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('5. Notifications'),
            const Text(
              'Admins can send notifications to users about updates, offers, or operational changes. Ensure all communications are professional and relevant.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('6. Prohibited Actions'),
            const Text(
              '- Misuse of admin privileges, such as unauthorized data deletion, altering user information, or abusive notifications, is strictly prohibited.\n'
              '- Violations may lead to the suspension or termination of admin rights.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('7. Liability Limitation'),
            const Text(
              'The app owner is not liable for any errors, misuse, or damages caused by admin actions. Admins are responsible for ensuring the smooth and lawful operation of their activities.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('8. Updates to Terms'),
            const Text(
              'The admin terms and conditions may be updated periodically. Admins will be notified of any significant changes and are expected to comply with the updated terms.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 30),
            Center(
              child: CustomButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: const ButtonStyle(),
                text: 'Agree and Continue',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
