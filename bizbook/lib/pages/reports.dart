import 'package:bizbook/backend/auth.dart';
import 'package:bizbook/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class UnpaidOrdersReportScreen extends StatefulWidget {
  const UnpaidOrdersReportScreen({super.key});

  @override
  State<UnpaidOrdersReportScreen> createState() =>
      _UnpaidOrdersReportScreenState();
}

class _UnpaidOrdersReportScreenState extends State<UnpaidOrdersReportScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _customersWithUnpaidOrders = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomersWithUnpaidOrders();
  }

  Future<void> _fetchCustomersWithUnpaidOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all customers
      final customersSnapshot = await _database.child('customers').get();
      final salesSnapshot = await _database.child('sales').get();

      if (customersSnapshot.exists && salesSnapshot.exists) {
        final customersData =
            Map<String, dynamic>.from(customersSnapshot.value as Map);
        final salesData = Map<String, dynamic>.from(salesSnapshot.value as Map);

        List<Map<String, dynamic>> customersWithUnpaid = [];

        // Process each customer
        customersData.forEach((customerId, customerData) {
          final customer = Map<String, dynamic>.from(customerData as Map);
          customer['id'] = customerId;

          // Find unpaid orders for this customer
          List<Map<String, dynamic>> unpaidOrders = [];
          num totalDueAmount = 0;

          salesData.forEach((salesId, salesData) {
            final sale = Map<String, dynamic>.from(salesData as Map);

            // Check if this sale belongs to the customer and is unpaid
            if (sale['customerId'] == customerId &&
                (sale['paymentMethod'] == 'Cash')) {
              sale['id'] = salesId;
              unpaidOrders.add(sale);
              totalDueAmount += num.parse(sale['amount'].toString());
            }
          });

          // Only add customers with unpaid orders
          if (unpaidOrders.isNotEmpty) {
            customer['unpaidOrders'] = unpaidOrders;
            customer['totalDueAmount'] = totalDueAmount;
            customersWithUnpaid.add(customer);
          }
        });

        setState(() {
          _customersWithUnpaidOrders = customersWithUnpaid;
          _filteredCustomers = customersWithUnpaid;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCustomers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = _customersWithUnpaidOrders;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredCustomers = _customersWithUnpaidOrders.where((customer) {
        final name = customer['name']?.toString().toLowerCase() ?? '';
        final email = customer['email']?.toString().toLowerCase() ?? '';
        final phone = customer['phoneNumber']?.toString().toLowerCase() ?? '';

        return name.contains(lowercaseQuery) ||
            email.contains(lowercaseQuery) ||
            phone.contains(lowercaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbaar("Unpaid Orders Report"),
      drawer: drawer(context, "Reports"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF5EFE6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterCustomers,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort by: Name',
                  style: TextStyle(
                    color: Color(0xFF8D6E63),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF8D6E63),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_filteredCustomers.length} customers',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCustomers.isEmpty
                    ? const Center(
                        child: Text('No customers with unpaid orders'))
                    : ListView.builder(
                        itemCount: _filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = _filteredCustomers[index];
                          final totalDue = customer['totalDueAmount'] ?? 0;
                          final unpaidOrders = List<Map<String, dynamic>>.from(
                              customer['unpaidOrders'] as List);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 4.0),
                            child: Card(
                              color: const Color(0xFFF5EFE6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CustomerDetailScreen(
                                        customer: customer,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color(0xFF8D6E63),
                                        child: Text(
                                          (customer['name'] as String?)
                                                      ?.isNotEmpty ==
                                                  true
                                              ? (customer['name'] as String)
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                              : '?',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customer['name'] ?? 'Unknown',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF8D6E63),
                                              ),
                                            ),
                                            Text(
                                              customer['email'] ?? 'No email',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₹${totalDue.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF8D6E63),
                                            ),
                                          ),
                                          Text(
                                            '${unpaidOrders.length} orders',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class CustomerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> customer;
  const CustomerDetailScreen({
    super.key,
    required this.customer,
  });

  Future<void> _sendPaymentReminder(BuildContext context) async {
    try {
      String whatsappUrl =
          'https://wa.me/${customer['phoneNumber']}?text=${Uri.encodeComponent('Dear ${customer['name']},\n\nThis is a friendly reminder that you have unpaid orders totaling ₹${customer['totalDueAmount'].toStringAsFixed(2)}. Please arrange for payment at your earliest convenience.\n\nThank you,\nBiZBook')}';

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      }
    } catch (error) {
      if (!context.mounted) return;
      AuthService().showToast(context, "Error sending reminder", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unpaidOrders =
        List<Map<String, dynamic>>.from(customer['unpaidOrders'] as List);
    final totalDue = customer['totalDueAmount'] ?? 0;

    return Scaffold(
      appBar: backAppBar(customer['name'] ?? 'Customer Details', context, []),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF8D6E63),
              child: Text(
                (customer['name'] as String?)?.isNotEmpty == true
                    ? (customer['name'] as String).substring(0, 1).toUpperCase()
                    : '?',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              customer['name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8D6E63),
              ),
            ),
            Text(
              'Customer since ${customer['createdAt'] ?? 'Unknown'}',
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
                        value: customer['email'] ?? 'No email',
                      ),
                      const SizedBox(height: 12),
                      _buildContactRow(
                        icon: Icons.phone,
                        title: 'Phone',
                        value: customer['phoneNumber'] ?? 'No phone',
                      ),
                      const SizedBox(height: 12),
                      _buildContactRow(
                        icon: Icons.location_on,
                        title: 'Address',
                        value: customer['address'] ?? 'No address',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () => _sendPaymentReminder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8D6E63),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Send Payment Reminder',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Unpaid Orders',
                  style: TextStyle(
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
                                'Order #${order['id']?.toString().substring(0, 8) ?? 'Unknown'}',
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
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
          Icon(icon, color: Color(0xFF8D6E63), size: 28),
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
          child: Icon(icon, color: Color(0xFF8D6E63), size: 20),
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
