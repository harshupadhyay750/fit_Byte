import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        'title': 'Time to drink water!',
        'body': 'Stay hydrated. You have 1,300ml left to reach your goal.',
        'time': '10 mins ago',
        'icon': 'water_drop',
      },
      {
        'title': 'Lunch Reminder',
        'body': 'Don\'t forget to log your meal to track your progress.',
        'time': '1 hour ago',
        'icon': 'restaurant',
      },
      {
        'title': 'Great Job!',
        'body': 'You reached your protein goal yesterday. Keep it up!',
        'time': 'Yesterday',
        'icon': 'celebration',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? const Center(child: Text('No new notifications'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(_getIcon(item['icon']!), color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(item['body']!),
                      const SizedBox(height: 4),
                      Text(item['time']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'water_drop': return Icons.water_drop;
      case 'restaurant': return Icons.restaurant;
      case 'celebration': return Icons.celebration;
      default: return Icons.notifications;
    }
  }
}
