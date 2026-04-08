import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_user_scope.dart';
import '../../../models/item_model.dart';

class ItemService {
  CollectionReference<Map<String, dynamic>> get _itemsCollection =>
      FirestoreUserScope.itemsCollection;

  Stream<List<ItemModel>> getItems() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    });
  }

  Future<ItemModel?> getItemById(String id) async {
    final doc = await _itemsCollection.doc(id).get();

    if (!doc.exists) return null;

    return ItemModel.fromFirestore(doc);
  }

  Future<void> addItem({
    required String name,
    required String sku,
    required int stock,
    required int minStock,
    required String unit,
    required String description,
  }) async {
    await _itemsCollection.add({
      'name': name,
      'sku': sku,
      'stock': stock,
      'minStock': minStock,
      'unit': unit,
      'description': description,
      'ownerUid': FirestoreUserScope.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateItem({
    required String id,
    required String name,
    required String sku,
    required int stock,
    required int minStock,
    required String unit,
    required String description,
  }) async {
    await _itemsCollection.doc(id).update({
      'name': name,
      'sku': sku,
      'stock': stock,
      'minStock': minStock,
      'unit': unit,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteItem(String id) async {
    await _itemsCollection.doc(id).delete();
  }
}