import 'package:flutter/material.dart';

import '../data/dashboard_service.dart';
import '../../../models/dashboard_summary_model.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  bool _isLoading = false;
  String? _errorMessage;
  DashboardSummaryModel? _summary;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardSummaryModel? get summary => _summary;

  Future<void> loadDashboardSummary() async {
    _setLoading(true);
    _clearError();

    try {
      _summary = await _dashboardService.getDashboardSummary();
    } catch (e) {
      _errorMessage = 'Gagal mengambil data dashboard';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await loadDashboardSummary();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}