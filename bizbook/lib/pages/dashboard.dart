import 'package:bizbook/pages/add_sale.dart';
import 'package:bizbook/pages/billing.dart';
import 'package:bizbook/pages/daily_summary.dart';
import 'package:bizbook/pages/inventory.dart';
import 'package:bizbook/pages/manage_customers.dart';
import 'package:bizbook/pages/profile.dart';
import 'package:bizbook/pages/reports.dart';
import 'package:bizbook/widget/appbar.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbaar('Dashboard', []),
      drawer: drawer(context, 'Dashboard'),
      body: Column(
        children: [
          // App Bar
          // Dashboard Content
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Daily Summary Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DailySummaryScreen(),
                          ),
                        );
                      },
                      child: DashboardCard(
                        title: 'Daily Summary',
                        icon: 'assets/document_icon.png',
                        height: 160,
                        width: double.infinity,
                        iconSize: 60,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Middle Row - Inventory and Customers
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InventoryScreen(),
                                ),
                              );
                            },
                            child: DashboardCard(
                              title: 'Inventory',
                              icon: 'assets/inventory_icon.png',
                              height: 160,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomersScreen(),
                                ),
                              );
                            },
                            child: DashboardCard(
                              title: 'Customers',
                              icon: 'assets/customers_icon.png',
                              height: 160,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Middle Row - Billings and Reports
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Billing(),
                                ),
                              );
                            },
                            child: DashboardCard(
                              title: 'Billings',
                              icon: 'assets/billings_icon.png',
                              height: 160,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UnpaidOrdersReportScreen(),
                                ),
                              );
                            },
                            child: DashboardCard(
                              title: 'Unpaid Orders',
                              icon: 'assets/reports_icon.png',
                              height: 160,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Bottom Row - Settings and Profile
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddSaleScreen(),
                                ),
                              );
                            },
                            child: DashboardCard(
                              title: 'Add Sales',
                              icon: 'assets/settings_icon.png',
                              height: 160,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(),
                                ),
                              );
                            },
                            child: DashboardCard(
                              title: 'Profile',
                              icon: 'assets/profile_icon.png',
                              height: 160,
                              useAvatar: true,
                            ),
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
    super.key,
    required this.title,
    required this.icon,
    required this.height,
    this.width,
    this.iconSize = 50,
    this.useAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.description;

    if (title == 'Inventory') {
      iconData = Icons.inventory_2;
    } else if (title == 'Customers') {
      iconData = Icons.people;
    } else if (title == 'Billings') {
      iconData = Icons.receipt;
    } else if (title == 'Reports') {
      iconData = Icons.bar_chart;
    } else if (title == 'Add Sales') {
      iconData = Icons.shopping_bag_outlined;
    } else if (title == 'Profile') {
      iconData = Icons.person;
    }
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
            Icon(
              iconData,
              size: iconSize,
              color: const Color(0xFF8B5E5A),
            ),
        ],
      ),
    );
  }
}
