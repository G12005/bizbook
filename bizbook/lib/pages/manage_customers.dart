import 'package:bizbook/backend/auth.dart';
import 'package:bizbook/backend/customer.dart';
import 'package:bizbook/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  CustomersScreenState createState() => CustomersScreenState();
}

class CustomersScreenState extends State<CustomersScreen> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('customers');
  final List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'name'; // Default sort
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() {
    _database.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _customers.clear();

        data.forEach((key, value) {
          final customer =
              Customer.fromMap(key, value as Map<dynamic, dynamic>);
          _customers.add(customer);
        });

        _sortCustomers();
        _filterCustomers();

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _customers.clear();
          _filteredCustomers.clear();
          _isLoading = false;
        });
      }
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _sortCustomers() {
    switch (_sortBy) {
      case 'name':
        _customers.sort((a, b) => _sortAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case 'totalSpent':
        _customers.sort((a, b) => _sortAscending
            ? a.totalSpent.compareTo(b.totalSpent)
            : b.totalSpent.compareTo(a.totalSpent));
        break;
      case 'totalOrders':
        _customers.sort((a, b) => _sortAscending
            ? a.totalOrders.compareTo(b.totalOrders)
            : b.totalOrders.compareTo(a.totalOrders));
        break;
      case 'createdAt':
        _customers.sort((a, b) => _sortAscending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  void _filterCustomers() {
    if (_searchQuery.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      _filteredCustomers = _customers.where((customer) {
        return customer.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            customer.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            customer.phoneNumber.contains(_searchQuery);
      }).toList();
    }
  }

  void _addCustomer() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditCustomerScreen(isNewCustomer: true),
      ),
    );
  }

  void _viewCustomerDetails(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailScreen(customer: customer),
      ),
    );
  }

  void _editCustomer(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomerScreen(
          isNewCustomer: false,
          customer: customer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(context, "Customers"),
      appBar: appbaar("Customers", []),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search customers',
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
                      _filterCustomers();
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
                        DropdownMenuItem(value: 'name', child: Text('Name')),
                        DropdownMenuItem(
                            value: 'totalSpent', child: Text('Total Spent')),
                        DropdownMenuItem(
                            value: 'totalOrders', child: Text('Orders')),
                        DropdownMenuItem(
                            value: 'createdAt', child: Text('Date Added')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortBy = value;
                            _sortCustomers();
                            _filterCustomers();
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
                          _sortCustomers();
                          _filterCustomers();
                        });
                      },
                    ),
                    const Spacer(),
                    // Customer count
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5E5A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_filteredCustomers.length} customers',
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

          // Customer list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCustomers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Color(0xFF8B5E5A),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No customers found'
                                  : 'No customers match your search',
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
                        itemCount: _filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = _filteredCustomers[index];
                          return CustomerListItem(
                            customer: customer,
                            onTap: () => _viewCustomerDetails(customer),
                            onEdit: () => _editCustomer(customer),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5E5A),
        onPressed: _addCustomer,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class CustomerListItem extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const CustomerListItem({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MMM d, yyyy');

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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Customer avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage:
                    customer.photoUrl != null && customer.photoUrl!.isNotEmpty
                        ? NetworkImage(customer.photoUrl!)
                        : null,
                child: customer.photoUrl == null || customer.photoUrl!.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF8B5E5A),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Customer details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5E5A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.email,
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
                          'Since ${dateFormat.format(customer.createdAt)}',
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
              // Customer stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${customer.totalSpent.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5E5A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${customer.totalOrders} orders',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5E5A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
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
  }
}

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
  });

  @override
  CustomerDetailScreenState createState() => CustomerDetailScreenState();
}

class CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: backAppBar(widget.customer.name, context, [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditCustomerScreen(
                  isNewCustomer: false,
                  customer: widget.customer,
                ),
              ),
            );
            // Refresh the page after editing
            if (!context.mounted) return;
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerDetailScreen(
                  customer: widget.customer,
                ),
              ),
            );
          },
        ),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: widget.customer.photoUrl != null &&
                            widget.customer.photoUrl!.isNotEmpty
                        ? NetworkImage(widget.customer.photoUrl!)
                        : null,
                    child: widget.customer.photoUrl == null ||
                            widget.customer.photoUrl!.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 70,
                            color: Color(0xFF8B5E5A),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.customer.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5E5A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customer since ${dateFormat.format(widget.customer.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Customer stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Spent',
                    '₹${widget.customer.totalSpent.toStringAsFixed(2)}',
                    Icons.currency_rupee,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Orders',
                    widget.customer.totalOrders.toString(),
                    Icons.shopping_cart,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Contact information
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5E5A),
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(Icons.email, 'Email', widget.customer.email),
            _buildContactItem(
                Icons.phone, 'Phone', widget.customer.phoneNumber),
            _buildContactItem(
                Icons.location_on, 'Address', widget.customer.address),
            const SizedBox(height: 32),

            // Order history
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5E5A),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<DatabaseEvent>(
              future: _database
                  .child('sales')
                  .orderByChild('customerId')
                  .equalTo(widget.customer.customerId)
                  .limitToLast(5)
                  .once(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData ||
                    snapshot.data?.snapshot.value == null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EBE6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('No orders found'),
                    ),
                  );
                }

                final orders = <Map<dynamic, dynamic>>[];
                final data =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                data.forEach((key, value) {
                  final order = value as Map<dynamic, dynamic>;
                  order['id'] = key;
                  orders.add(order);
                });

                // Sort orders by date (newest first)
                orders.sort((a, b) =>
                    (b['date'] as String).compareTo(a['date'] as String));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderDate = DateTime.parse(order['date'] as String);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EBE6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order['id'].toString().substring(0, 8)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B5E5A),
                                ),
                              ),
                              Text(
                                dateFormat.format(orderDate),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(order['items'] as List?)?.length ?? 0} items',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                '₹${(order['amount'] ?? 0.0).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B5E5A),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EBE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF8B5E5A),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B5E5A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EBE6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8B5E5A),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditCustomerScreen extends StatefulWidget {
  final bool isNewCustomer;
  final Customer? customer;

  const EditCustomerScreen({
    super.key,
    required this.isNewCustomer,
    this.customer,
  });

  @override
  EditCustomerScreenState createState() => EditCustomerScreenState();
}

class EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('customers');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isNewCustomer && widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _emailController.text = widget.customer!.email;
      _phoneController.text = widget.customer!.phoneNumber;
      _addressController.text = widget.customer!.address;
      _passwordController.text = widget.customer!.password;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final customerData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'phoneNumber': _phoneController.text,
        'address': _addressController.text,
        'createdAt': widget.isNewCustomer
            ? now.toIso8601String().split('T')[0]
            : widget.customer!.createdAt.toIso8601String().split('T')[0],
        'totalSpent': widget.isNewCustomer ? 0.0 : widget.customer!.totalSpent,
        'totalOrders': widget.isNewCustomer ? 0 : widget.customer!.totalOrders,
        'photoUrl':
            widget.isNewCustomer ? '' : (widget.customer!.photoUrl ?? ''),
      };

      if (widget.isNewCustomer) {
        final newCustomerRef = _database.push();
        await newCustomerRef.set(customerData);
        final uniqueKey = newCustomerRef.key;
        if (uniqueKey!.isNotEmpty) {
          final customerData = {
            'name': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'phoneNumber': _phoneController.text,
            'customerId': uniqueKey,
            'address': _addressController.text,
            'createdAt': widget.isNewCustomer
                ? now.toIso8601String().split('T')[0]
                : widget.customer!.createdAt.toIso8601String().split('T')[0],
            'totalSpent':
                widget.isNewCustomer ? 0.0 : widget.customer!.totalSpent,
            'totalOrders':
                widget.isNewCustomer ? 0 : widget.customer!.totalOrders,
            'photoUrl':
                widget.isNewCustomer ? '' : (widget.customer!.photoUrl ?? ''),
          };
          await _database.child(uniqueKey).update(customerData);
        }
      } else {
        await _database.child(widget.customer!.id).update(customerData);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AuthService().showToast(
          context, "Could not save customer: ${e.toString()}", false);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCustomer() async {
    if (widget.isNewCustomer) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text(
            'Are you sure you want to delete this customer? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _database.child(widget.customer!.id).remove();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AuthService().showToast(context, "Error deleting customer", false);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: backAppBar(
          widget.isNewCustomer ? 'Add Customer' : 'Edit Customer', context, [
        if (!widget.isNewCustomer)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteCustomer,
          ),
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        // Simple email validation
                        final emailRegExp =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegExp.hasMatch(value ?? "")) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a address';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveCustomer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7BA37E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.isNewCustomer ? 'Add Customer' : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
