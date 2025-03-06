import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // App Bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: const Color(0xFF7BA37E),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: Colors.white, size: 28),
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Stack(
                    children: [
                      const Icon(Icons.notifications,
                          color: Colors.white, size: 28),
                      Positioned(
                        right: 0,
                        top: 0,
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
                          child: const Text(
                            '1',
                            style: TextStyle(
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
              ),
            ),
          ),

          // Dashboard Content
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Daily Summary Card
                    DashboardCard(
                      title: 'Daily Summary',
                      icon: 'assets/document_icon.png',
                      height: 160,
                      width: double.infinity,
                      iconSize: 60,
                    ),

                    const SizedBox(height: 16),

                    // Middle Row - Inventory and Customers
                    Row(
                      children: [
                        Expanded(
                          child: DashboardCard(
                            title: 'Inventory',
                            icon: 'assets/inventory_icon.png',
                            height: 160,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardCard(
                            title: 'Customers',
                            icon: 'assets/customers_icon.png',
                            height: 160,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Middle Row - Billings and Reports
                    Row(
                      children: [
                        Expanded(
                          child: DashboardCard(
                            title: 'Billings',
                            icon: 'assets/billings_icon.png',
                            height: 160,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardCard(
                            title: 'Reports',
                            icon: 'assets/reports_icon.png',
                            height: 160,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Bottom Row - Settings and Profile
                    Row(
                      children: [
                        Expanded(
                          child: DashboardCard(
                            title: 'Settings',
                            icon: 'assets/settings_icon.png',
                            height: 160,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardCard(
                            title: 'Profile',
                            icon: 'assets/profile_icon.png',
                            height: 160,
                            useAvatar: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String icon;
  final double height;
  final double? width;
  final double iconSize;
  final bool useAvatar;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.height,
    this.width,
    this.iconSize = 50,
    this.useAvatar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EBE6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B5E5A),
            ),
          ),
          const SizedBox(height: 16),
          if (useAvatar)
            Container(
              width: iconSize,
              height: iconSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFCCCCCC),
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            )
          else
            Image.asset(
              icon,
              width: iconSize,
              height: iconSize,
              // Fallback to placeholder icons if assets aren't available
              errorBuilder: (context, error, stackTrace) {
                IconData iconData = Icons.description;

                if (title == 'Inventory')
                  iconData = Icons.inventory_2;
                else if (title == 'Customers')
                  iconData = Icons.people;
                else if (title == 'Billings')
                  iconData = Icons.receipt;
                else if (title == 'Reports')
                  iconData = Icons.bar_chart;
                else if (title == 'Settings')
                  iconData = Icons.settings;
                else if (title == 'Profile') iconData = Icons.person;

                return Icon(
                  iconData,
                  size: iconSize,
                  color: const Color(0xFF8B5E5A),
                );
              },
            ),
        ],
      ),
    );
  }
}
