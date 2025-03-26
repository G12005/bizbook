import 'package:bizbook/backend/auth.dart';
import 'package:bizbook/backend/inventory.dart';
import 'package:bizbook/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

// class InventoryItem {
//   final String id;
//   final String name;
//   final double price;
//   final String imageUrl;

//   InventoryItem({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.imageUrl,
//   });

//   factory InventoryItem.fromMap(String id, Map<dynamic, dynamic> map) {
//     return InventoryItem(
//       id: id,
//       name: map['name'] ?? 'Unknown Item',
//       price: (map['price'] ?? 0.0).toDouble(),
//       imageUrl: map['imageUrl'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'price': price,
//       'imageUrl': imageUrl,
//     };
//   }
// }

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  InventoryScreenState createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('inventory');
  final List<InventoryItem> _inventoryItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
  }

  void _loadInventoryItems() {
    _database.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _inventoryItems.clear();

        data.forEach((key, value) {
          final item =
              InventoryItem.fromMap(key, value as Map<dynamic, dynamic>);
          _inventoryItems.add(item);
        });

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _inventoryItems.clear();
          _isLoading = false;
        });
      }
    }, onError: (error) {
      if (!mounted) return;
      AuthService().showToast(context, "Error loading inventory", false);
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _addInventoryItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInventoryItemScreen(
          isNewItem: true,
        ),
      ),
    );

    if (result == true) {
      if (!mounted) return;
      AuthService().showToast(context, "Item added successfully", true);
    }
  }

  void _editInventoryItem(InventoryItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInventoryItemScreen(
          isNewItem: false,
          item: item,
        ),
      ),
    );

    if (result == true) {
      // Item was updated, refresh will happen automatically due to Firebase listener
      if (!mounted) return;
      AuthService().showToast(context, "Item updated successfully", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbaar('Inventory'),
      drawer: drawer(context, 'Inventory'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inventoryItems.isEmpty
              ? const Center(child: Text('No inventory items found'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _inventoryItems.length,
                  itemBuilder: (context, index) {
                    final item = _inventoryItems[index];
                    return InventoryItemCard(
                      item: item,
                      onEdit: () => _editInventoryItem(item),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF8B5E5A),
        onPressed: _addInventoryItem,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onEdit;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2EBE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.imageUrl.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.black54,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.image,
                      size: 80,
                      color: Colors.black54,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  '₹${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5E5A),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: InkWell(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5E5A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditInventoryItemScreen extends StatefulWidget {
  final bool isNewItem;
  final InventoryItem? item;

  const EditInventoryItemScreen({
    super.key,
    required this.isNewItem,
    this.item,
  });

  @override
  EditInventoryItemScreenState createState() => EditInventoryItemScreenState();
}

class EditInventoryItemScreenState extends State<EditInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('inventory');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _imageFile;
  String _imageUrl = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isNewItem && widget.item != null) {
      _nameController.text = widget.item!.name;
      _priceController.text = widget.item!.price.toString();
      _qtyController.text = widget.item!.quantity.toString();
      _imageUrl = widget.item!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_imageFile == null) return _imageUrl;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String fileName =
          'inventory_image_${timestamp}_${path.basename(_imageFile!.path)}';
      final storageRef = _storage.ref().child('inventory_images/$fileName');
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (!mounted) return '';
      AuthService().showToast(context, "Error uploading image", false);
      return '';
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image if selected
      final imageUrl = await _uploadImage();

      final item = InventoryItem(
        id: widget.isNewItem ? '' : widget.item!.id,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        imageUrl: imageUrl,
        quantity: int.parse(_qtyController.text),
        createdAt: widget.isNewItem ? DateTime.now() : widget.item!.createdAt,
        updatedAt: DateTime.now(),
        lastTimeStamp: DateTime.now(),
      );

      if (widget.isNewItem) {
        // Add new item
        final newItemRef = _database.push();
        await newItemRef.set(item.toMap());
      } else {
        // Update existing item
        await _database.child(widget.item!.id).update(item.toMap());
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AuthService().showToast(context, "Failed to save item", false);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem() async {
    if (widget.isNewItem) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _database.child(widget.item!.id).remove();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AuthService().showToast(context, "Failed to delete item", false);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: backAppBar(
        widget.isNewItem ? 'Add Inventory Item' : 'Edit Inventory Item',
        context,
        [
          if (!widget.isNewItem)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteItem,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2EBE6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tap to add image',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an item name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _qtyController,
                      decoration: const InputDecoration(
                        labelText: 'Qty',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Qty';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7BA37E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.isNewItem ? 'Add Item' : 'Save Changes',
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
