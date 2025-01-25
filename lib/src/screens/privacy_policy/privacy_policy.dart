import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Data Collection'),
            _buildPolicyItem('We collect login credentials via SharedPreferences'),
            _buildPolicyItem('User order details are fetched from Firebase'),
            _buildPolicyItem('Order status updates are tracked and managed'),

            _buildSectionTitle('Data Usage'),
            _buildPolicyItem('Login data used for authentication'),
            _buildPolicyItem('Order details used for tracking and management'),
            _buildPolicyItem('Push notifications provide order status updates'),

            _buildSectionTitle('Data Security'),
            _buildPolicyItem('Login credentials stored securely'),
            _buildPolicyItem('Firebase provides encrypted data storage'),
            _buildPolicyItem('Secure mechanisms for order status updates'),

            _buildSectionTitle('User Consent'),
            _buildPolicyItem('User consent required for order tracking'),
            _buildPolicyItem('Option to opt-in/opt-out of notifications'),

            _buildSectionTitle('User Rights'),
            _buildPolicyItem('View and modify order status'),
            _buildPolicyItem('Access to personal order information'),

            const SizedBox(height: 20),
            Center(
              child: Text(
                'Last Updated: January 2024',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPolicyItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0, top: 4.0),
            child: Icon(Icons.check_circle, size: 16, color: Colors.blue),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}