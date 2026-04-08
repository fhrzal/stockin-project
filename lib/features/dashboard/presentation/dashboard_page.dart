import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../../../models/dashboard_summary_model.dart';
import '../provider/dashboard_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class DashboardColors {
  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5EAF2);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color primary = Color(0xFF4F46E5);
  static const Color primarySoft = Color(0xFFEAEAFE);

  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFECFDF3);

  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFFF7ED);

  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFEF2F2);

  static const Color info = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFEFF6FF);

  static const Color darkCardTop = Color(0xFF1E293B);
  static const Color darkCardBottom = Color(0xFF334155);
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedRange = '7D';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  Future<void> _loadDashboard() async {
    await context.read<DashboardProvider>().loadDashboardSummary();
  }

  Future<void> _refreshDashboard() async {
    await context.read<DashboardProvider>().refresh();
  }

  String _getUserName(String? email) {
    if (email == null || email.trim().isEmpty) return 'User';
    return email.split('@').first;
  }

  List<DashboardAnalyticsPoint> _getSelectedInPoints(
      DashboardSummaryModel? summary,
      ) {
    if (summary == null) return const [];

    switch (_selectedRange) {
      case '1M':
        return summary.analyticsIn1m;
      case '3M':
        return summary.analyticsIn3m;
      case '7D':
      default:
        return summary.analyticsIn7d;
    }
  }

  List<DashboardAnalyticsPoint> _getSelectedOutPoints(
      DashboardSummaryModel? summary,
      ) {
    if (summary == null) return const [];

    switch (_selectedRange) {
      case '1M':
        return summary.analyticsOut1m;
      case '3M':
        return summary.analyticsOut3m;
      case '7D':
      default:
        return summary.analyticsOut7d;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();

    final summary = dashboardProvider.summary;
    final lowStockItems = summary?.lowStockItemList ?? [];
    final userName = _getUserName(authProvider.currentUser?.email);
    final inPoints = _getSelectedInPoints(summary);
    final outPoints = _getSelectedOutPoints(summary);

    if (dashboardProvider.isLoading && summary == null) {
      return const _DashboardLoadingState();
    }

    if (dashboardProvider.errorMessage != null && summary == null) {
      return _DashboardErrorState(
        message: dashboardProvider.errorMessage!,
        onRetry: _refreshDashboard,
      );
    }

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: DashboardColors.primary,
          onRefresh: _refreshDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _TopBar(userName: userName),
              const SizedBox(height: 16),

              _OverviewCard(
                userName: userName,
                totalItems: summary?.totalItems ?? 0,
                lowStockItems: summary?.lowStockItems ?? 0,
              ),
              const SizedBox(height: 16),

              _AnalyticsCard(
                selectedRange: _selectedRange,
                inPoints: inPoints,
                outPoints: outPoints,
                onRangeChanged: (value) {
                  setState(() {
                    _selectedRange = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.02,
                children: [
                  _StatCard(
                    title: 'Total Barang',
                    value: '${summary?.totalItems ?? 0}',
                    subtitle: 'Item terdaftar',
                    icon: Icons.inventory_2_rounded,
                    iconBg: DashboardColors.infoSoft,
                    iconColor: DashboardColors.info,
                    accentColor: DashboardColors.info,
                    badgeText: 'Inventory',
                  ),
                  _StatCard(
                    title: 'Stok Minimum',
                    value: '${summary?.lowStockItems ?? 0}',
                    subtitle: 'Perlu perhatian',
                    icon: Icons.warning_amber_rounded,
                    iconBg: DashboardColors.warningSoft,
                    iconColor: DashboardColors.warning,
                    accentColor: DashboardColors.warning,
                    badgeText: 'Alert',
                  ),
                  _StatCard(
                    title: 'Barang Masuk',
                    value: '${summary?.totalStockInTransactions ?? 0}',
                    subtitle: 'Total transaksi',
                    icon: Icons.south_west_rounded,
                    iconBg: DashboardColors.successSoft,
                    iconColor: DashboardColors.success,
                    accentColor: DashboardColors.success,
                    badgeText: 'Inbound',
                  ),
                  _StatCard(
                    title: 'Barang Keluar',
                    value: '${summary?.totalStockOutTransactions ?? 0}',
                    subtitle: 'Total transaksi',
                    icon: Icons.north_east_rounded,
                    iconBg: DashboardColors.dangerSoft,
                    iconColor: DashboardColors.danger,
                    accentColor: DashboardColors.danger,
                    badgeText: 'Outbound',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _SectionHeader(
                title: 'Stok yang mencapai minimum',
                badgeText:
                lowStockItems.isNotEmpty ? '${lowStockItems.length} item' : null,
              ),
              const SizedBox(height: 12),

              if (lowStockItems.isEmpty)
                const _SafeStockCard()
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DashboardColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: DashboardColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A0F172A),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: List.generate(lowStockItems.length, (index) {
                      final item = lowStockItems[index];

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == lowStockItems.length - 1 ? 0 : 10,
                        ),
                        child: _LowStockTile(item: item),
                      );
                    }),
                  ),
                ),

              if (dashboardProvider.errorMessage != null && summary != null) ...[
                const SizedBox(height: 16),
                _InlineWarningCard(
                  message: dashboardProvider.errorMessage!,
                  onRetry: _refreshDashboard,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String userName;

  const _TopBar({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: DashboardColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Halo, $userName',
                style: const TextStyle(
                  fontSize: 14,
                  color: DashboardColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: DashboardColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DashboardColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: DashboardColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String userName;
  final int totalItems;
  final int lowStockItems;

  const _OverviewCard({
    required this.userName,
    required this.totalItems,
    required this.lowStockItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            DashboardColors.darkCardTop,
            DashboardColors.darkCardBottom,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Icon(
                  Icons.warehouse_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warehouse Overview',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Pantau kondisi stok gudang secara ringkas dan cepat.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _OverviewBadge(
                  label: 'Total Barang',
                  value: '$totalItems',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewBadge(
                  label: 'Stok Minimum',
                  value: '$lowStockItems',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewBadge extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewBadge({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String selectedRange;
  final List<DashboardAnalyticsPoint> inPoints;
  final List<DashboardAnalyticsPoint> outPoints;
  final ValueChanged<String> onRangeChanged;

  const _AnalyticsCard({
    required this.selectedRange,
    required this.inPoints,
    required this.outPoints,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeInPoints = inPoints.isEmpty
        ? const [
      DashboardAnalyticsPoint(label: 'N/A', value: 0),
    ]
        : inPoints;

    final safeOutPoints = outPoints.isEmpty
        ? List.generate(
      safeInPoints.length,
          (index) => DashboardAnalyticsPoint(
        label: safeInPoints[index].label,
        value: 0,
      ),
    )
        : outPoints;

    final totalIn = safeInPoints.fold<double>(0, (sum, item) => sum + item.value);
    final totalOut =
    safeOutPoints.fold<double>(0, (sum, item) => sum + item.value);

    final currentCombined = (safeInPoints.isNotEmpty ? safeInPoints.last.value : 0) +
        (safeOutPoints.isNotEmpty ? safeOutPoints.last.value : 0);

    final previousCombined = safeInPoints.length > 1 && safeOutPoints.length > 1
        ? safeInPoints[safeInPoints.length - 2].value +
        safeOutPoints[safeOutPoints.length - 2].value
        : 0;

    final growth = previousCombined == 0
        ? 0
        : ((currentCombined - previousCombined) / previousCombined) * 100;

    final positive = growth >= 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: DashboardColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: DashboardColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pergerakan barang masuk dan keluar',
                      style: TextStyle(
                        fontSize: 13,
                        color: DashboardColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _RangeChip(
                label: '7D',
                isSelected: selectedRange == '7D',
                onTap: () => onRangeChanged('7D'),
              ),
              const SizedBox(width: 6),
              _RangeChip(
                label: '1M',
                isSelected: selectedRange == '1M',
                onTap: () => onRangeChanged('1M'),
              ),
              const SizedBox(width: 6),
              _RangeChip(
                label: '3M',
                isSelected: selectedRange == '3M',
                onTap: () => onRangeChanged('3M'),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (totalIn + totalOut).toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: DashboardColors.textPrimary,
                  letterSpacing: -0.8,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: positive
                      ? DashboardColors.successSoft
                      : DashboardColors.dangerSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${positive ? '+' : ''}${growth.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: positive
                        ? DashboardColors.success
                        : DashboardColors.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            selectedRange == '7D'
                ? 'total aktivitas 7 hari terakhir'
                : selectedRange == '1M'
                ? 'total aktivitas 4 pekan terakhir'
                : 'total aktivitas 3 bulan terakhir',
            style: const TextStyle(
              fontSize: 12,
              color: DashboardColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _AnalyticsLegendChip(
                  title: 'Masuk',
                  value: totalIn.toStringAsFixed(0),
                  color: DashboardColors.success,
                  softColor: DashboardColors.successSoft,
                  icon: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AnalyticsLegendChip(
                  title: 'Keluar',
                  value: totalOut.toStringAsFixed(0),
                  color: DashboardColors.danger,
                  softColor: DashboardColors.dangerSoft,
                  icon: Icons.north_east_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 240,
            child: LineChart(
              _buildChartData(
                inPoints: safeInPoints,
                outPoints: safeOutPoints,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData({
    required List<DashboardAnalyticsPoint> inPoints,
    required List<DashboardAnalyticsPoint> outPoints,
  }) {
    final labels = inPoints.map((e) => e.label).toList();

    final inMax = inPoints.fold<double>(
      0,
          (prev, item) => item.value > prev ? item.value : prev,
    );
    final outMax = outPoints.fold<double>(
      0,
          (prev, item) => item.value > prev ? item.value : prev,
    );

    final maxValue = inMax > outMax ? inMax : outMax;
    final maxY = maxValue <= 0 ? 10.0 : maxValue + (maxValue * 0.30);

    return LineChartData(
      minX: 0,
      maxX: (labels.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (_) {
          return const FlLine(
            color: Color(0xFFEAEFF5),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 34,
            showTitles: true,
            interval: maxY / 4,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 11,
                  color: DashboardColors.textMuted,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= labels.length) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  labels[index],
                  style: const TextStyle(
                    fontSize: 11,
                    color: DashboardColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 14,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              final label = labels[index];
              final isInLine = spot.barIndex == 0;

              return LineTooltipItem(
                isInLine
                    ? '$label\nMasuk: ${spot.y.toStringAsFixed(0)}'
                    : '$label\nKeluar: ${spot.y.toStringAsFixed(0)}',
                TextStyle(
                  color: isInLine
                      ? DashboardColors.successSoft
                      : DashboardColors.dangerSoft,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.35,
          barWidth: 3,
          color: DashboardColors.success,
          isStrokeCapRound: true,
          spots: List.generate(
            inPoints.length,
                (index) => FlSpot(index.toDouble(), inPoints[index].value),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3.6,
                color: DashboardColors.success,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                DashboardColors.success.withOpacity(0.16),
                DashboardColors.success.withOpacity(0.01),
              ],
            ),
          ),
        ),
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.35,
          barWidth: 3,
          color: DashboardColors.danger,
          isStrokeCapRound: true,
          spots: List.generate(
            outPoints.length,
                (index) => FlSpot(index.toDouble(), outPoints[index].value),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3.6,
                color: DashboardColors.danger,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsLegendChip extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Color softColor;
  final IconData icon;

  const _AnalyticsLegendChip({
    required this.title,
    required this.value,
    required this.color,
    required this.softColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DashboardColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DashboardColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? DashboardColors.primarySoft
                : DashboardColors.background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? DashboardColors.primary.withOpacity(0.15)
                  : DashboardColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? DashboardColors.primary
                  : DashboardColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? badgeText;

  const _SectionHeader({
    required this.title,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: DashboardColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (badgeText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: DashboardColors.warningSoft,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: DashboardColors.warning.withOpacity(0.12),
              ),
            ),
            child: Text(
              badgeText!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: DashboardColors.warning,
              ),
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String badgeText;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color accentColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.badgeText,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFF8FAFC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: DashboardColors.border,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: -22,
              right: -22,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -28,
              left: -28,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              iconBg,
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: accentColor.withOpacity(0.10),
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: accentColor.withOpacity(0.10),
                          ),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: DashboardColors.textPrimary,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DashboardColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: DashboardColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LowStockTile extends StatelessWidget {
  final LowStockItemModel item;

  const _LowStockTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final int stock = item.stock;
    final int minStock = item.minStock;
    final String name = item.name;

    final bool critical = stock <= 0;

    final Color accentColor =
    critical ? DashboardColors.danger : DashboardColors.warning;
    final Color softColor =
    critical ? DashboardColors.dangerSoft : DashboardColors.warningSoft;
    final String statusText = critical ? 'Habis' : 'Minimum';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              critical ? Icons.error_outline_rounded : Icons.inventory_2_outlined,
              color: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DashboardColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok $stock • Minimum $minStock',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DashboardColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeStockCard extends StatelessWidget {
  const _SafeStockCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DashboardColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: DashboardColors.successSoft,
            child: Icon(
              Icons.check_circle_rounded,
              color: DashboardColors.success,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Semua stok dalam kondisi aman.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DashboardColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineWarningCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _InlineWarningCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardColors.warningSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashboardColors.warning.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: DashboardColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: DashboardColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => onRetry(),
            child: const Text('Muat ulang'),
          ),
        ],
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: DashboardColors.primary,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Memuat dashboard...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _DashboardErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: DashboardColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: DashboardColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A0F172A),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: DashboardColors.dangerSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: DashboardColors.danger,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: DashboardColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: DashboardColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => onRetry(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DashboardColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Coba Lagi',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}