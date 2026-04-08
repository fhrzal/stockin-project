import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String itemId;
  final String itemName;
  final String type; // in / out
  final int quantity;
  final String description;
  final String createdBy;
  final Timestamp? createdAt;

  TransactionModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.description,
    required this.createdBy,
    this.createdAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      itemName: data['itemName'] ?? '',
      type: data['type'] ?? '',
      quantity: data['quantity'] ?? 0,
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'type': type,
      'quantity': quantity,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}