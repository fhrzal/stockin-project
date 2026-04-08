import 'package:flutter/material.dart';

import '../../../models/item_model.dart';
import '../../../models/transaction_model.dart';
import '../data/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<List<TransactionModel>> getTransactions() {
    return _transactionService.getTransactions();
  }

  Future<bool> addStockIn({
    required ItemModel item,
    required int quantity,
    required String description,
    required String createdBy,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _transactionService.addStockIn(
        item: item,
        quantity: quantity,
        description: description,
        createdBy: createdBy,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addStockOut({
    required ItemModel item,
    required int quantity,
    required String description,
    required String createdBy,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _transactionService.addStockOut(
        item: item,
        quantity: quantity,
        description: description,
        createdBy: createdBy,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
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