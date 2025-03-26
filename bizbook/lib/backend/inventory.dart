class InventoryItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastTimeStamp;

  InventoryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.lastTimeStamp,
  });

  bool get isLowStock => quantity < 10;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'lastTimeStamp': DateTime.now().millisecondsSinceEpoch,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InventoryItem.fromMap(String id, Map<dynamic, dynamic> map) {
    return InventoryItem(
      id: id,
      name: map['name'] ?? 'Unknown Item',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      lastTimeStamp: map['lastTimeStamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastTimeStamp'])
          : DateTime.now(),
    );
  }

  InventoryItem copyWith({
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? category,
    String? description,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastTimeStamp: lastTimeStamp,
    );
  }
}
