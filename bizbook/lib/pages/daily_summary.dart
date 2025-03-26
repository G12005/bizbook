import 'package:bizbook/backend/sale_model.dart';
import 'package:bizbook/pages/sale_detail.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:bizbook/widget/appbar.dart';
import 'package:bizbook/repositories/database_repository.dart';

class DailySummaryScreen extends StatefulWidget {
  const DailySummaryScreen({super.key});

  @override
  DailySummaryScreenState createState() => DailySummaryScreenState();
}

class DailySummaryScreenState extends State<DailySummaryScreen> {
  final DatabaseRepository _repository = DatabaseRepository();
  bool _isLoading = true;
  int _notificationCount = 1;

  // Summary data
  double _todayRevenue = 0.0;
  double _weeklyRevenue = 0.0;
  int _todaySales = 0;
  int _newCustomers = 0;
  int _totalInventory = 0;
  int _lowStockItems = 0;
  List<Sale> _recentSales = [];

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    // Listen for changes in sales
    FirebaseDatabase.instance.ref().child('sales').onValue.listen((_) {
      _loadSummaryData();
    });

    // Listen for changes in customers
    FirebaseDatabase.instance.ref().child('customers').onValue.listen((_) {
      _loadSummaryData();
    });

    // Listen for changes in inventory
    FirebaseDatabase.instance.ref().child('inventory').onValue.listen((_) {
      _loadSummaryData();
    });
  }

  Future<void> _loadSummaryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final summary = await _repository.getDailySummary();

      setState(() {
        _todaySales = summary['todaySales'];
        _todayRevenue = summary['todayRevenue'];
        _weeklyRevenue = summary['weeklyRevenue'];
        _newCustomers = summary['newCustomers'];
        _totalInventory = summary['totalInventory'];
        _lowStockItems = summary['lowStockItems'];
        _recentSales = summary['recentSales'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading summary data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: backAppBar(
        "Daily Summary",
        context,
        [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: Colors.white, size: 28),
                onPressed: () {
                  // Show notifications
                  setState(() {
                    _notificationCount = 0; // Clear notifications when viewed
                  });
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
      ),
      body: RefreshIndicator(
        onRefresh: _loadSummaryData,
        color: const Color(0xFF7BA37E),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5E5A)))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date header
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5E5A),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Revenue summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EBE6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Revenue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5E5A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Today',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF8B5E5A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFormat.format(_todayRevenue),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8B5E5A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'This Week',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF8B5E5A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFormat.format(_weeklyRevenue),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8B5E5A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Sales',
                            _todaySales.toString(),
                            Icons.shopping_cart,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'New Customers',
                            _newCustomers.toString(),
                            Icons.person_add,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Inventory Items',
                            _totalInventory.toString(),
                            Icons.inventory_2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Low Stock Items',
                            _lowStockItems.toString(),
                            Icons.warning_amber,
                            isWarning: _lowStockItems > 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent transactions
                    const Text(
                      'Today\'s Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5E5A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EBE6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _recentSales.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  'No recent transactions',
                                  style: TextStyle(
                                    color: Color(0xFF8B5E5A),
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _recentSales.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                height: 1,
                                color: Color(0xFFE5D6CC),
                              ),
                              itemBuilder: (context, index) {
                                final sale = _recentSales[index];
                                return ListTile(
                                  title: Text(
                                    sale.customerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8B5E5A),
                                    ),
                                  ),
                                  subtitle: Text(
                                    DateFormat('MMM d, yyyy • h:mm a')
                                        .format(sale.date),
                                    style: TextStyle(
                                      color: Color(0xFF8B5E5A),
                                    ),
                                  ),
                                  trailing: Text(
                                    currencyFormat.format(sale.amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8B5E5A),
                                    ),
                                  ),
                                  onTap: () {
                                    // Navigate to sale details
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SaleDetailScreen(
                                          sale: sale,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EBE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isWarning ? Colors.amber : const Color(0xFF8B5E5A),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B5E5A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color:
                  isWarning ? Colors.amber.shade800 : const Color(0xFF8B5E5A),
            ),
          ),
        ],
      ),
    );
  }
}
