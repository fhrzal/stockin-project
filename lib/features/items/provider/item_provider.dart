import 'package:flutter/material.dart';

import '../../../models/item_model.dart';
import '../data/item_service.dart';

class ItemProvider with ChangeNotifier {
  final ItemService _itemService = ItemService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<List<ItemModel>> getItems() {
    return _itemService.getItems();
  }

  Future<ItemModel?> getItemById(String id) async {
    try {
      return await _itemService.getItemById(id);
    } catch (e) {
      _errorMessage = 'Gagal mengambil detail barang';
      notifyListeners();
      return null;
    }
  }

  Future<bool> addItem({
    required String name,
    required String sku,
    required int stock,
    required int minStock,
    required String unit,
    required String description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _itemService.addItem(
        name: name,
        sku: sku,
        stock: stock,
        minStock: minStock,
        unit: unit,
        description: description,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan barang';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateItem({
    required String id,
    required String name,
    required String sku,
    required int stock,
    required int minStock,
    required String unit,
    required String description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _itemService.updateItem(
        id: id,
        name: name,
        sku: sku,
        stock: stock,
        minStock: minStock,
        unit: unit,
        description: description,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate barang';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteItem(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _itemService.deleteItem(id);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus barang';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}