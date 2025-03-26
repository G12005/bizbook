class Customer {
  final String id;
  final String name;
  final String email;
  final String customerId;
  final String password;
  final String phoneNumber;
  final String address;
  final DateTime createdAt;
  final double totalSpent;
  final int totalOrders;
  final String? photoUrl;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.customerId,
    required this.phoneNumber,
    required this.address,
    required this.createdAt,
    required this.totalSpent,
    required this.totalOrders,
    required this.password,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'customerId': customerId,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt':
          createdAt.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'totalSpent': totalSpent,
      'totalOrders': totalOrders,
      'photoUrl': photoUrl,
    };
  }

  factory Customer.fromMap(String id, Map<dynamic, dynamic> map) {
    String dateStr =
        map['createdAt'] ?? DateTime.now().toIso8601String().split('T')[0];

    DateTime createdDate;
    try {
      createdDate = DateTime.parse(dateStr);
    } catch (e) {
      createdDate = DateTime.now();
    }

    return Customer(
      id: id,
      name: map['name'] ?? 'Unknown',
      email: map['email'] ?? '',
      customerId: map['customerId'] ?? '',
      password: map['password'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      createdAt: createdDate,
      totalSpent: (map['totalSpent'] ?? 0.0).toDouble(),
      totalOrders: (map['totalOrders'] ?? 0).toInt(),
      photoUrl: map['photoUrl'],
    );
  }
}
