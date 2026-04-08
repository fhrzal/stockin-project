import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String name;
  final String sku;
  final int stock;
  final int minStock;
  final String unit;
  final String description;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.stock,
    required this.minStock,
    required this.unit,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      sku: data['sku'] ?? '',
      stock: data['stock'] ?? 0,
      minStock: data['minStock'] ?? 0,
      unit: data['unit'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'stock': stock,
      'minStock': minStock,
      'unit': unit,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}