import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_user_scope.dart';
import '../../../models/item_model.dart';
import '../../../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _itemsCollection =>
      FirestoreUserScope.itemsCollection;

  CollectionReference<Map<String, dynamic>> get _transactionsCollection =>
      FirestoreUserScope.transactionsCollection;

  Stream<List<TransactionModel>> getTransactions() {
    return _transactionsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addStockIn({
    required ItemModel item,
    required int quantity,
    required String description,
    required String createdBy,
  }) async {
    final itemRef = _itemsCollection.doc(item.id);
    final transactionRef = _transactionsCollection.doc();

    await _firestore.runTransaction((transaction) async {
      final itemSnapshot = await transaction.get(itemRef);

      if (!itemSnapshot.exists) {
        throw Exception('Barang tidak ditemukan');
      }

      final data = itemSnapshot.data() as Map<String, dynamic>;
      final currentStock = data['stock'] ?? 0;
      final newStock = currentStock + quantity;

      transaction.update(itemRef, {
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(transactionRef, {
        'itemId': item.id,
        'itemName': item.name,
        'type': 'in',
        'quantity': quantity,
        'description': description,
        'createdBy': createdBy,
        'ownerUid': FirestoreUserScope.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> addStockOut({
    required ItemModel item,
    required int quantity,
    required String description,
    required String createdBy,
  }) async {
    final itemRef = _itemsCollection.doc(item.id);
    final transactionRef = _transactionsCollection.doc();

    await _firestore.runTransaction((transaction) async {
      final itemSnapshot = await transaction.get(itemRef);

      if (!itemSnapshot.exists) {
        throw Exception('Barang tidak ditemukan');
      }

      final data = itemSnapshot.data() as Map<String, dynamic>;
      final currentStock = data['stock'] ?? 0;

      if (currentStock < quantity) {
        throw Exception('Stok tidak mencukupi');
      }

      final newStock = currentStock - quantity;

      transaction.update(itemRef, {
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(transactionRef, {
        'itemId': item.id,
        'itemName': item.name,
        'type': 'out',
        'quantity': quantity,
        'description': description,
        'createdBy': createdBy,
        'ownerUid': FirestoreUserScope.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}