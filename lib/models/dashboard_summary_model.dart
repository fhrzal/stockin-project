class LowStockItemModel {
  final String id;
  final String name;
  final int stock;
  final int minStock;

  const LowStockItemModel({
    required this.id,
    required this.name,
    required this.stock,
    required this.minStock,
  });

  factory LowStockItemModel.fromMap(Map<String, dynamic> map, String id) {
    return LowStockItemModel(
      id: id,
      name: (map['name'] ?? map['itemName'] ?? '-').toString(),
      stock: _toInt(map['stock']),
      minStock: _toInt(map['minStock'] ?? map['minimumStock']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class DashboardAnalyticsPoint {
  final String label;
  final double value;

  const DashboardAnalyticsPoint({
    required this.label,
    required this.value,
  });
}

class DashboardSummaryModel {
  final int totalItems;
  final int lowStockItems;
  final int totalStockInTransactions;
  final int totalStockOutTransactions;
  final List<LowStockItemModel> lowStockItemList;

  final List<DashboardAnalyticsPoint> analyticsIn7d;
  final List<DashboardAnalyticsPoint> analyticsOut7d;

  final List<DashboardAnalyticsPoint> analyticsIn1m;
  final List<DashboardAnalyticsPoint> analyticsOut1m;

  final List<DashboardAnalyticsPoint> analyticsIn3m;
  final List<DashboardAnalyticsPoint> analyticsOut3m;

  const DashboardSummaryModel({
    required this.totalItems,
    required this.lowStockItems,
    required this.totalStockInTransactions,
    required this.totalStockOutTransactions,
    required this.lowStockItemList,
    required this.analyticsIn7d,
    required this.analyticsOut7d,
    required this.analyticsIn1m,
    required this.analyticsOut1m,
    required this.analyticsIn3m,
    required this.analyticsOut3m,
  });
}