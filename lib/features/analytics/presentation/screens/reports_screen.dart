import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/utils/currency_formatter.dart';
import 'package:spendra/core/utils/date_utils.dart';
import 'package:spendra/core/widgets/empty_state.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/expense/domain/entities/expense.dart';

enum ReportPeriod { month, quarter, year }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.month;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allExpenses = ref.watch(allExpensesStreamProvider).valueOrNull ?? [];
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? [];
    final currency = ref.watch(currencyCodeProvider);
    final symbol = CurrencyFormatter.symbol(currency);
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final periodExpenses = _filterByPeriod(allExpenses);
    final expenseOnly = periodExpenses.where((e) => e.isExpense).toList();
    final incomeOnly = periodExpenses.where((e) => e.isIncome).toList();

    final totalSpent = expenseOnly.fold(0.0, (s, e) => s + e.amount);
    final totalIncome = incomeOnly.fold(0.0, (s, e) => s + e.amount);

    final distribution = _buildCategoryDistribution(expenseOnly, categories);
    final trend = _buildTrend(allExpenses);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.base,
                  AppSpacing.base,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reports', style: theme.textTheme.headlineMedium),
                    _PeriodDropdown(
                      selected: _period,
                      onChanged: (p) => setState(() => _period = p),
                    ),
                  ],
                ),
              ),
            ),

            // ── Total Spending Card ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.base,
                  AppSpacing.base,
                  0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: AppRadii.xlRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL SPENDING',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: textSecondary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '$symbol ${CurrencyFormatter.formatAmount(totalSpent)}',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: AppColors.coral,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'INCOME',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: textSecondary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                '$symbol ${CurrencyFormatter.formatAmount(totalIncome)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.teal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      if (distribution.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        // Donut Chart
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sections: distribution.asMap().entries.map((e) {
                                final i = e.key;
                                final item = e.value;
                                final isTouched = _touchedIndex == i;
                                return PieChartSectionData(
                                  value: item.amount,
                                  color: item.color,
                                  radius: isTouched ? 70 : 60,
                                  title: isTouched
                                      ? '${(item.percentage * 100).toInt()}%'
                                      : '',
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                );
                              }).toList(),
                              centerSpaceRadius: 50,
                              sectionsSpace: 3,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null) {
                                      _touchedIndex = null;
                                      return;
                                    }
                                    _touchedIndex = response
                                        .touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.base),

                        // Legend
                        Wrap(
                          spacing: AppSpacing.base,
                          runSpacing: AppSpacing.sm,
                          children: distribution.map((item) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  item.label,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ] else
                        const Padding(
                          padding: EdgeInsets.only(top: AppSpacing.xl),
                          child: Center(
                            child: Text(
                              'No expense data for this period',
                              style: TextStyle(color: AppColors.darkTextSecondary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Spending Trend ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.xl,
                  AppSpacing.base,
                  0,
                ),
                child: Text('Spending Trend', style: theme.textTheme.headlineSmall),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.base,
                  AppSpacing.base,
                  0,
                ),
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.base,
                    AppSpacing.base,
                    AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: AppRadii.lgRadius,
                  ),
                  child: trend.isEmpty
                      ? const Center(
                          child: Text(
                            'Add transactions to see your trend',
                            style: TextStyle(color: AppColors.darkTextSecondary),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final maxAmount = trend
                                .map((t) => t.amount)
                                .fold(0.0, (a, b) => a > b ? a : b);
                            final chartMaxY = maxAmount <= 0 ? 100.0 : maxAmount * 1.3;

                            return BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: chartMaxY,
                                barGroups: trend.asMap().entries.map((e) {
                                  return BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.amount,
                                        color: AppColors.coral,
                                        width: 20,
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(6),
                                        ),
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: chartMaxY,
                                          color: isDark
                                              ? AppColors.darkSurfaceElevated
                                              : AppColors.lightSurfaceElevated,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() < trend.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              trend[value.toInt()].label,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: textSecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),

            // ── Top Categories ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.xl,
                  AppSpacing.base,
                  0,
                ),
                child: Text('Top Categories', style: theme.textTheme.headlineSmall),
              ),
            ),

            if (distribution.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.pie_chart_outline,
                  title: 'No data yet',
                  subtitle: 'Add expenses to see category breakdowns.',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final item = distribution[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.base,
                        AppSpacing.sm,
                        AppSpacing.base,
                        0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.base),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: AppRadii.lgRadius,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.15),
                                borderRadius: AppRadii.mdRadius,
                              ),
                              child: Icon(Icons.category,
                                  color: item.color, size: 20),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.label,
                                      style: theme.textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: AppRadii.pillRadius,
                                    child: LinearProgressIndicator(
                                      value: item.percentage,
                                      minHeight: 4,
                                      backgroundColor: isDark
                                          ? AppColors.darkSurfaceElevated
                                          : AppColors.lightSurfaceElevated,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              item.color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$symbol ${CurrencyFormatter.formatAmount(item.amount)}',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(color: AppColors.coral),
                                ),
                                Text(
                                  '${(item.percentage * 100).toInt()}%',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: distribution.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  List<Expense> _filterByPeriod(List<Expense> all) {
    final now = DateTime.now();
    return switch (_period) {
      ReportPeriod.month => all
          .where((e) => e.date.year == now.year && e.date.month == now.month)
          .toList(),
      ReportPeriod.quarter => all.where((e) {
          final start = DateTime(now.year, now.month - 2, 1);
          final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          return AppDateUtils.isWithinRange(e.date, start, end);
        }).toList(),
      ReportPeriod.year =>
        all.where((e) => e.date.year == now.year).toList(),
    };
  }

  List<_CategoryDistItem> _buildCategoryDistribution(
    List<Expense> expenses,
    List<Category> categories,
  ) {
    if (expenses.isEmpty) return [];

    final totals = <String, double>{};
    for (final e in expenses) {
      totals[e.categoryId] = (totals[e.categoryId] ?? 0) + e.amount;
    }
    final totalSpent = totals.values.fold(0.0, (a, b) => a + b);
    if (totalSpent == 0) return [];

    final result = totals.entries.map((entry) {
      final cat = categories
          .where((c) => c.id == entry.key)
          .firstOrNull;
      return _CategoryDistItem(
        label: cat?.name ?? 'Other',
        amount: entry.value,
        percentage: entry.value / totalSpent,
        color: cat != null
            ? AppColors.fromToken(cat.colorToken)
            : AppColors.darkTextSecondary,
      );
    }).toList();

    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result.take(6).toList();
  }

  List<_TrendItem> _buildTrend(List<Expense> all) {
    final items = <_TrendItem>[];
    for (int i = 5; i >= 0; i--) {
      final (start, end) = AppDateUtils.monthRange(i);
      final amount = all
          .where((e) =>
              e.isExpense &&
              AppDateUtils.isWithinRange(e.date, start, end))
          .fold(0.0, (s, e) => s + e.amount);
      items.add(_TrendItem(
        label: AppDateUtils.formatShortMonth(start),
        amount: amount,
      ));
    }
    return items;
  }
}

class _CategoryDistItem {
  const _CategoryDistItem({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });
  final String label;
  final double amount;
  final double percentage;
  final Color color;
}

class _TrendItem {
  const _TrendItem({required this.label, required this.amount});
  final String label;
  final double amount;
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({
    required this.selected,
    required this.onChanged,
  });

  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadii.pillRadius,
      ),
      child: DropdownButton<ReportPeriod>(
        value: selected,
        underline: const SizedBox.shrink(),
        isDense: true,
        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        style: theme.textTheme.labelLarge,
        items: ReportPeriod.values.map((p) {
          return DropdownMenuItem(
            value: p,
            child: Text(switch (p) {
              ReportPeriod.month => 'Monthly Report',
              ReportPeriod.quarter => 'Quarterly Report',
              ReportPeriod.year => 'Yearly Report',
            }),
          );
        }).toList(),
        onChanged: (p) => p != null ? onChanged(p) : null,
      ),
    );
  }
}
