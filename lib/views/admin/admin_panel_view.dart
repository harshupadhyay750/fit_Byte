import 'package:flutter/material.dart';

class AdminPanelView extends StatelessWidget {
  const AdminPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildAdminCard(context, 'Manage Users', Icons.group, Colors.blue),
          _buildAdminCard(context, 'Manage Foods', Icons.restaurant, Colors.orange),
          _buildAdminCard(context, 'Meal Plans', Icons.assignment, Colors.green),
          _buildAdminCard(context, 'Analytics', Icons.bar_chart, Colors.purple),
          _buildAdminCard(context, 'Notifications', Icons.campaign, Colors.red),
          _buildAdminCard(context, 'Settings', Icons.settings, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
