import 'package:bizbook/backend/auth.dart';
import 'package:bizbook/cus_page/cus_auth.dart';
import 'package:bizbook/pages/login.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CusDashboard extends StatefulWidget {
  const CusDashboard({super.key});

  @override
  State<CusDashboard> createState() => _CusDashboardState();
}

class _CusDashboardState extends State<CusDashboard> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? _customerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomerData();
  }

  Future<void> _fetchCustomerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get customerId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId');

      if (customerId == null) {
        throw Exception("Customer ID not found in SharedPreferences");
      }

      // Fetch customer data from Firebase Realtime Database
      final customerSnapshot =
          await _database.child('customers').child(customerId).get();

      if (customerSnapshot.exists) {
        final customerData =
            Map<String, dynamic>.from(customerSnapshot.value as Map);

        // Fetch unpaid orders for the customer
        final ordersSnapshot = await _database
            .child('sales')
            .orderByChild('customerId')
            .equalTo(customerId)
            .get();

        List<Map<String, dynamic>> unpaidOrders = [];
        if (ordersSnapshot.exists) {
          final ordersData =
              Map<String, dynamic>.from(ordersSnapshot.value as Map);

          unpaidOrders = ordersData.entries
              .where((entry) => entry.value['paymentMethod'] == 'Cash')
              .map((entry) {
            final order = Map<String, dynamic>.from(entry.value);
            order['key'] = entry.key; // Store the key
            return order;
          }).toList();
        }

        setState(() {
          _customerData = {
            ...customerData,
            'unpaidOrders': unpaidOrders,
          };
          _isLoading = false;
        });
      } else {
        throw Exception("Customer data not found in the database");
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching customer data: $error");
    }
  }

  Future<void> payComplete(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId');

      if (customerId == null) {
        throw Exception("Customer ID not found in SharedPreferences");
      }

      final unpaidOrders =
          List<Map<String, dynamic>>.from(_customerData?['unpaidOrders'] ?? []);

      if (unpaidOrders.isEmpty) {
        if (!context.mounted) return;
        AuthService().showToast(context, "No unpaid orders to process.", false);
        return;
      }

      for (var order in unpaidOrders) {
        final orderKey = order['key'];
        if (orderKey != null) {
          // Update the payment method to "PAID" in the sales table
          await _database
              .child('sales')
              .child(orderKey)
              .update({'paymentMethod': 'PAID'});
        }
      }

      // Calculate total amount paid
      final totalAmount = unpaidOrders.fold<double>(
        0,
        (sum, order) => sum + (order['amount'] ?? 0),
      );

      // Add a new entry to the payments table
      final paymentEntry = {
        'customerId': customerId,
        'amount': totalAmount,
        'date': DateTime.now().toIso8601String(),
        'orders': unpaidOrders.map((order) => order['key']).toList(),
      };

      await _database.child('payments').push().set(paymentEntry);

      // Refresh customer data
      await _fetchCustomerData();

      if (!context.mounted) return;
      AuthService().showToast(context, "Payment completed successfully.", true);
    } catch (error) {
      if (!context.mounted) return;
      AuthService().showToast(context, "Error completing payment", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_customerData == null) {
      return const Scaffold(
        body: Center(
          child: Text("Failed to load customer data"),
        ),
      );
    }

    final unpaidOrders =
        List<Map<String, dynamic>>.from(_customerData?['unpaidOrders'] ?? []);
    final totalDue = unpaidOrders.fold<double>(
      0,
      (sum, order) => sum + (order['amount'] ?? 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Dashboard'),
        backgroundColor: const Color(0xFF8D6E63),
        actions: [
          TextButton(
            onPressed: () async {
              await CusAuth().signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            child: Text(
              "Logout",
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF8D6E63),
              child: Text(
                (_customerData?['name'] as String?)?.isNotEmpty == true
                    ? (_customerData?['name'] as String)
                        .substring(0, 1)
                        .toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _customerData?['name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8D6E63),
              ),
            ),
            Text(
              'Customer since ${_customerData?['createdAt'] ?? 'Unknown'}',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoCard(
                  icon: Icons.currency_rupee,
                  title: '₹${totalDue.toStringAsFixed(2)}',
                  subtitle: 'Total Due',
                ),
                _buildInfoCard(
                  icon: Icons.shopping_cart,
                  title: '${unpaidOrders.length}',
                  subtitle: 'Unpaid Orders',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: const Color(0xFFF5EFE6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildContactRow(
                        icon: Icons.email,
                        title: 'Email',
                        value: _customerData?['email'] ?? 'No email',
                      ),
                      const SizedBox(height: 12),
                      _buildContactRow(
                        icon: Icons.phone,
                        title: 'Phone',
                        value: _customerData?['phoneNumber'] ?? 'No phone',
                      ),
                      const SizedBox(height: 12),
                      _buildContactRow(
                        icon: Icons.location_on,
                        title: 'Address',
                        value: _customerData?['address'] ?? 'No address',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            unpaidOrders.isEmpty
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Unpaid Orders',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: unpaidOrders.length,
              itemBuilder: (context, index) {
                final order = unpaidOrders[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Card(
                    color: const Color(0xFFF5EFE6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${unpaidOrders[index]['key']?.toString().substring(0, 8) ?? 'Unknown'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8D6E63),
                                ),
                              ),
                              Text(
                                order['date'] ?? 'Unknown date',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${order['items']?.length ?? 0} items',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '₹${order['amount']?.toString() ?? '0.00'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8D6E63),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment: ${order['paymentMethod'] ?? 'Unknown'}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Unpaid',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            unpaidOrders.isEmpty
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () => payComplete(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8D6E63),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Pay Online',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF8D6E63), size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8D6E63),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEAE0D5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF8D6E63), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
