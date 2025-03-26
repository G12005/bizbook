class Sale {
  final String id;
  final String customerId;
  final String customerName;
  final double amount;
  final DateTime date;
  final List<SaleItem> items;
  final String paymentMethod;
  final String notes;
  final int timestamp;

  Sale({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.date,
    required this.items,
    required this.paymentMethod,
    this.notes = '',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'amount': amount,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'items': items.map((item) => item.toMap()).toList(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };
  }

  factory Sale.fromMap(String id, Map<dynamic, dynamic> map) {
    List<SaleItem> items = [];
    if (map['items'] != null) {
      final itemsList = map['items'] as List;
      items = itemsList.map((item) => SaleItem.fromMap(item)).toList();
    }

    String dateStr =
        map['date'] ?? DateTime.now().toIso8601String().split('T')[0];
    String timeStr = map['time'] ?? '00:00';

    DateTime saleDate;
    try {
      saleDate = DateTime.parse('$dateStr $timeStr');
    } catch (e) {
      saleDate = DateTime.now();
    }

    return Sale(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Unknown',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: saleDate,
      items: items,
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      notes: map['notes'] ?? '',
      timestamp: (map['timestamp'] is int)
          ? map['timestamp'] as int
          : (map['timestamp'] is double)
              ? (map['timestamp'] as double).toInt()
              : int.tryParse(map['timestamp'].toString()) ?? 0,
    );
  }
}

class SaleItem {
  final String itemId;
  final String itemName;
  final double price;
  final int quantity;
  final String? imageUrl;

  SaleItem({
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'price': price,
      'quantity': quantity,
      'total': total,
      'imageUrl': imageUrl,
    };
  }

  factory SaleItem.fromMap(Map<dynamic, dynamic> map) {
    return SaleItem(
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? 'Unknown Item',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 1).toInt(),
      imageUrl: map['imageUrl'],
    );
  }
}
