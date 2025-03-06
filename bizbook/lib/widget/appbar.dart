import 'package:bizbook/pages/dashboard.dart';
import 'package:flutter/material.dart';

Widget drawer(BuildContext context, String name) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Color(0xFF7BA37E),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFF7BA37E),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'User Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                'user@example.com',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Dashboard'),
          selected: name == "Dashboard" ? true : false,
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Dashboard(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.inventory),
          title: const Text('Inventory'),
          selected: name == "Inventory" ? true : false,
          selectedTileColor: Colors.green.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Customers'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to customers
          },
        ),
        ListTile(
          leading: const Icon(Icons.receipt),
          title: const Text('Billings'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to billings
          },
        ),
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Reports'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to reports
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to settings
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            Navigator.pop(context);
            // Implement logout functionality
          },
        ),
      ],
    ),
  );
}

AppBar appbaar(String name) {
  int _notificationCount = 1; // Example notification count
  return AppBar(
    backgroundColor: const Color(0xFF7BA37E),
    title: Text(
      name,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    leading: Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    ),
    actions: [
      Stack(
        children: [
          IconButton(
            icon:
                const Icon(Icons.notifications, color: Colors.white, size: 28),
            onPressed: () {
              // Show notifications
              _notificationCount = 0; // Clear notifications when viewed
            },
          ),
          if (_notificationCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  _notificationCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    ],
  );
}
