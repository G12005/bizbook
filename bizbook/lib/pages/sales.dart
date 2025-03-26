import 'package:bizbook/backend/sale_model.dart';
import 'package:bizbook/pages/add_sale.dart';
import 'package:bizbook/pages/sale_detail.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:bizbook/widget/appbar.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  SalesScreenState createState() => SalesScreenState();
}

class SalesScreenState extends State<SalesScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Sale> _sales = [];
  bool _isLoading = true;
  String _searchQuery = '';
  List<Sale> _filteredSales = [];
  String _sortBy = 'date'; // Default sort
  bool _sortAscending = false; // Newest first by default
  int _notificationCount = 1; // Example notification count

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final salesSnapshot = await _database.child('sales').once();
      if (salesSnapshot.snapshot.value != null) {
        final salesData = salesSnapshot.snapshot.value as Map<dynamic, dynamic>;
        _sales = [];

        salesData.forEach((key, value) {
          final sale = Sale.fromMap(key, value as Map<dynamic, dynamic>);
          _sales.add(sale);
        });

        _sortSales();
        _filterSales();

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _sales = [];
          _filteredSales = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading sales: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sortSales() {
    switch (_sortBy) {
      case 'date':
        _sales.sort((a, b) => _sortAscending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date));
        break;
      case 'amount':
        _sales.sort((a, b) => _sortAscending
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount));
        break;
      case 'customerName':
        _sales.sort((a, b) => _sortAscending
            ? a.customerName.compareTo(b.customerName)
            : b.customerName.compareTo(a.customerName));
        break;
    }
  }

  void _filterSales() {
    if (_searchQuery.isEmpty) {
      _filteredSales = List.from(_sales);
    } else {
      _filteredSales = _sales.where((sale) {
        return sale.customerName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            sale.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            sale.amount.toString().contains(_searchQuery);
      }).toList();
    }
  }

  void _addSale() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSaleScreen(),
      ),
    );

    if (result == true) {
      _loadSales();
    }
  }

  void _viewSaleDetails(Sale sale) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaleDetailScreen(sale: sale),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: backAppBar(
        "Sales",
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search sales',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF2EBE6),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterSales();
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Sort by:',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: [
                        DropdownMenuItem(value: 'date', child: Text('Date')),
                        DropdownMenuItem(
                            value: 'amount', child: Text('Amount')),
                        DropdownMenuItem(
                            value: 'customerName', child: Text('Customer')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortBy = value;
                            _sortSales();
                            _filterSales();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _sortAscending = !_sortAscending;
                          _sortSales();
                          _filterSales();
                        });
                      },
                    ),
                    const Spacer(),
                    // Sales count
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5E5A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_filteredSales.length} sales',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sales list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B5E5A)))
                : _filteredSales.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Color(0xFF8B5E5A),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No sales found'
                                  : 'No sales match your search',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF8B5E5A),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredSales.length,
                        itemBuilder: (context, index) {
                          final sale = _filteredSales[index];
                          return SaleListItem(
                            sale: sale,
                            onTap: () => _viewSaleDetails(sale),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7BA37E),
        onPressed: _addSale,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class SaleListItem extends StatelessWidget {
  final Sale sale;
  final VoidCallback onTap;

  const SaleListItem({
    super.key,
    required this.sale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EBE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sale.customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5E5A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '₹${sale.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5E5A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(sale.date),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(sale.date),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5E5A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sale.paymentMethod,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B5E5A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${sale.items.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
