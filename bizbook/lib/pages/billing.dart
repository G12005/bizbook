import 'package:bizbook/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class Billing extends StatefulWidget {
  const Billing({super.key});

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('payments');
  final List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    _database.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _payments.clear();

        data.forEach((key, value) {
          final payment = Map<String, dynamic>.from(value as Map);
          payment['id'] = key; // Add the payment ID
          _payments.add(payment);
        });

        // Sort payments by date (newest first)
        _payments.sort((a, b) =>
            DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _payments.clear();
          _isLoading = false;
        });
      }
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbaar("Billing", []),
      drawer: drawer(context, "Billings"),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Recent Payments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5E5A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5E5A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_payments.length} payments',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Payments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _payments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.payment_outlined,
                              size: 80,
                              color: Color(0xFF8B5E5A),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No payments found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF8B5E5A),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _payments.length,
                        itemBuilder: (context, index) {
                          final payment = _payments[index];
                          return PaymentListItem(payment: payment);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class PaymentListItem extends StatelessWidget {
  final Map<String, dynamic> payment;

  const PaymentListItem({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MMM d, yyyy hh:mm a');
    final DateTime paymentDate = DateTime.parse(payment['date']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EBE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle payment details view
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Payment Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment ID: ${payment['id']}'),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Amount: ₹${payment['amount']}'),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Date: ${dateFormat.format(paymentDate)}'),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Customer ID: ${payment['customerId']}'),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Orders: ${payment['orders'].join(', ')}'),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Payment icon
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.payment,
                  size: 30,
                  color: Color(0xFF8B5E5A),
                ),
              ),
              const SizedBox(width: 16),
              // Payment details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${payment['amount']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5E5A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer ID: ${payment['customerId']}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(paymentDate),
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
              // Orders count
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${payment['orders'].length} orders',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5E5A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5E5A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.white,
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
