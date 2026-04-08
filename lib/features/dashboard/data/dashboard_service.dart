import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_user_scope.dart';
import '../../../models/dashboard_summary_model.dart';

class DashboardService {
  Future<DashboardSummaryModel> getDashboardSummary() async {
    final itemsSnapshot = await FirestoreUserScope.itemsCollection.get();
    final transactionsSnapshot =
    await FirestoreUserScope.transactionsCollection.get();

    final lowStockItems = itemsSnapshot.docs
        .map((doc) => LowStockItemModel.fromMap(doc.data(), doc.id))
        .where((item) => item.stock <= item.minStock)
        .toList()
      ..sort((a, b) {
        final aCritical = a.stock <= 0 ? 0 : 1;
        final bCritical = b.stock <= 0 ? 0 : 1;

        if (aCritical != bCritical) {
          return aCritical.compareTo(bCritical);
        }

        return a.stock.compareTo(b.stock);
      });

    final transactions = transactionsSnapshot.docs
        .map((doc) => doc.data())
        .toList();

    final stockInTransactions = transactions
        .where((data) => (data['type'] ?? '').toString() == 'in')
        .toList();

    final stockOutTransactions = transactions
        .where((data) => (data['type'] ?? '').toString() == 'out')
        .toList();

    return DashboardSummaryModel(
      totalItems: itemsSnapshot.size,
      lowStockItems: lowStockItems.length,
      totalStockInTransactions: stockInTransactions.length,
      totalStockOutTransactions: stockOutTransactions.length,
      lowStockItemList: lowStockItems,
      analyticsIn7d: _build7DaysAnalytics(transactions, type: 'in'),
      analyticsOut7d: _build7DaysAnalytics(transactions, type: 'out'),
      analyticsIn1m: _build1MonthAnalytics(transactions, type: 'in'),
      analyticsOut1m: _build1MonthAnalytics(transactions, type: 'out'),
      analyticsIn3m: _build3MonthsAnalytics(transactions, type: 'in'),
      analyticsOut3m: _build3MonthsAnalytics(transactions, type: 'out'),
    );
  }

  List<DashboardAnalyticsPoint> _build7DaysAnalytics(
      List<Map<String, dynamic>> transactions, {
        required String type,
      }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<DashboardAnalyticsPoint> points = [];

    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));

      final total = transactions
          .where((data) => (data['type'] ?? '').toString() == type)
          .where((data) {
        final date = _readDate(data);
        return date != null && _isSameDay(date, day);
      }).fold<double>(0, (sum, data) => sum + _readQuantity(data));

      points.add(
        DashboardAnalyticsPoint(
          label: _dayLabel(day.weekday),
          value: total,
        ),
      );
    }

    return points;
  }

  List<DashboardAnalyticsPoint> _build1MonthAnalytics(
      List<Map<String, dynamic>> transactions, {
        required String type,
      }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<DashboardAnalyticsPoint> points = [];

    for (int i = 0; i < 4; i++) {
      final start = today.subtract(Duration(days: 27 - (i * 7)));
      final end = start.add(const Duration(days: 7));

      final total = transactions
          .where((data) => (data['type'] ?? '').toString() == type)
          .where((data) {
        final date = _readDate(data);
        return date != null && !date.isBefore(start) && date.isBefore(end);
      }).fold<double>(0, (sum, data) => sum + _readQuantity(data));

      points.add(
        DashboardAnalyticsPoint(
          label: 'P${i + 1}',
          value: total,
        ),
      );
    }

    return points;
  }

  List<DashboardAnalyticsPoint> _build3MonthsAnalytics(
      List<Map<String, dynamic>> transactions, {
        required String type,
      }) {
    final now = DateTime.now();
    final List<DashboardAnalyticsPoint> points = [];

    for (int i = 2; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final nextMonthStart = DateTime(now.year, now.month - i + 1, 1);

      final total = transactions
          .where((data) => (data['type'] ?? '').toString() == type)
          .where((data) {
        final date = _readDate(data);
        return date != null &&
            !date.isBefore(monthStart) &&
            date.isBefore(nextMonthStart);
      }).fold<double>(0, (sum, data) => sum + _readQuantity(data));

      points.add(
        DashboardAnalyticsPoint(
          label: _monthLabel(monthStart.month),
          value: total,
        ),
      );
    }

    return points;
  }

  DateTime? _readDate(Map<String, dynamic> data) {
    final raw =
        data['createdAt'] ?? data['transactionDate'] ?? data['date'] ?? data['timestamp'];

    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is String) return DateTime.tryParse(raw);

    return null;
  }

  double _readQuantity(Map<String, dynamic> data) {
    final value = data['quantity'] ?? data['qty'] ?? data['totalQty'] ?? 0;

    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;

    return 0;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Sen';
      case DateTime.tuesday:
        return 'Sel';
      case DateTime.wednesday:
        return 'Rab';
      case DateTime.thursday:
        return 'Kam';
      case DateTime.friday:
        return 'Jum';
      case DateTime.saturday:
        return 'Sab';
      case DateTime.sunday:
        return 'Min';
      default:
        return '';
    }
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return months[month - 1];
  }
}