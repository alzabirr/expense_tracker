import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/router/route_names.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_shadows.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/utils/currency_formatter.dart';
import 'package:spendra/core/utils/date_utils.dart';
import 'package:spendra/core/widgets/amount_display.dart';
import 'package:spendra/core/widgets/empty_state.dart';
import 'package:spendra/core/widgets/section_header.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/category/presentation/widgets/category_chip.dart';
import 'package:spendra/features/expense/domain/entities/expense.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final currency = ref.watch(currencyCodeProvider);
    final symbol = CurrencyFormatter.symbol(currency);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Balance Card ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.base,
                  AppSpacing.base,
                  0,
                ),
                child: _BalanceCard(
                  balance: summary.totalBalance,
                  income: summary.totalIncome,
                  expense: summary.totalExpense,
                  symbol: symbol,
                ),
              ),
            ),
          ),

          // ── Budget Progress ───────────────────────────────────────────
          if (summary.budgetAmount > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.base,
                  AppSpacing.base,
                  0,
                ),
                child: _BudgetCard(
                  spent: summary.budgetSpent,
                  total: summary.budgetAmount,
                  progress: summary.budgetProgress,
                  remaining: summary.budgetRemaining,
                  symbol: symbol,
                ),
              ),
            ),

          // ── Recent Section: Empty State OR Recent Activity ──────────
          if (summary.recentTransactions.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'No transactions yet',
                    subtitle: 'Add your first expense or income to get started.',
                  ),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.xl,
                  AppSpacing.base,
                  AppSpacing.sm,
                ),
                child: SectionHeader(
                  title: 'Recent Activity',
                  actionLabel: 'See All',
                  onAction: () => context.go(RouteNames.transactions),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final expense = summary.recentTransactions[i];
                  return _RecentTile(expense: expense, symbol: symbol);
                },
                childCount: summary.recentTransactions.length,
              ),
            ),
          ],

          // Bottom padding for floating nav bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }
}

// ── Balance Card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatefulWidget {
  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
    required this.symbol,
  });

  final double balance;
  final double income;
  final double expense;
  final String symbol;

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _hideBalance = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final formattedBalance = CurrencyFormatter.formatAmount(widget.balance.abs());
    final displayBalance = _hideBalance
        ? '••••••'
        : '${widget.balance < 0 ? '-' : ''}${widget.symbol} $formattedBalance';

    final formattedIncome = CurrencyFormatter.formatAmount(widget.income);
    final displayIncome = _hideBalance ? '••••••' : '+${widget.symbol} $formattedIncome';

    final formattedSpent = CurrencyFormatter.formatAmount(widget.expense);
    final displaySpent = _hideBalance ? '••••••' : '-${widget.symbol} $formattedSpent';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A1D) : AppColors.lightSurface,
        borderRadius: AppRadii.xlRadius,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header: Total Balance
                    Text(
                      'Total Balance',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Amount
                    Text(
                      displayBalance,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontSize: 34,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _hideBalance = !_hideBalance),
                behavior: HitTestBehavior.opaque,
                child: _WalletGraphic(isOpen: !_hideBalance),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Row displaying Income and Spent side by side
          Row(
            children: [
              // Income Pill Badge
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_upward_rounded,
                        size: 15,
                        color: AppColors.teal,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Income',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                displayIncome,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Spent Pill Badge
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_downward_rounded,
                        size: 15,
                        color: AppColors.coral,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Spent',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                displaySpent,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.coral,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletGraphic extends StatelessWidget {
  const _WalletGraphic({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 115,
      height: 105,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Red credit card (slides higher up when open)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: isOpen ? 6 : 22,
            right: 14,
            child: Transform.rotate(
              angle: isOpen ? -0.10 : -0.05,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isOpen ? 1.0 : 0.75,
                child: Container(
                  width: 76,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 18,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Dark Wallet container (no shadow)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 104,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFF22252A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Stack(
                children: [
                  // Metallic Latch Tab on right side (no shadow)
                  Positioned(
                    right: 0,
                    top: 22,
                    child: Container(
                      width: 28,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF181A1E),
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(15),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: const BoxDecoration(
                            color: Color(0xFF9E9E9E),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Budget Card ───────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.spent,
    required this.total,
    required this.progress,
    required this.remaining,
    required this.symbol,
  });

  final double spent;
  final double total;
  final double progress;
  final double remaining;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final trackColor = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;

    final Color progressColor;
    if (progress >= 1.0) {
      progressColor = AppColors.danger;
    } else if (progress >= 0.8) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.coral;
    }

    final daysLeft = AppDateUtils.endOfMonth.difference(DateTime.now()).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadii.lgRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Budget',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '${(progress * 100).toInt()}% used',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadii.pillRadius,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutExpo,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You have $symbol ${CurrencyFormatter.formatAmount(remaining.clamp(0, double.infinity))} left for $daysLeft day${daysLeft == 1 ? '' : 's'}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Tile ───────────────────────────────────────────────────────────────

class _RecentTile extends ConsumerWidget {
  const _RecentTile({required this.expense, required this.symbol});

  final Expense expense;
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? [];
    final Category? category = categories.where((c) => c.id == expense.categoryId).firstOrNull;

    final isIncome = expense.isIncome;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        0,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push(RouteNames.transactionDetailPath(expense.id)),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadii.lgRadius,
            border: isIncome
                ? Border.all(
                    color: AppColors.teal.withValues(alpha: 0.35),
                    width: 1.2,
                  )
                : null,
          ),
          child: Row(
            children: [
              if (category != null)
                CategoryAvatar(category: category)
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isIncome
                        ? AppColors.teal.withValues(alpha: 0.16)
                        : AppColors.darkSurfaceElevated,
                    borderRadius: AppRadii.mdRadius,
                  ),
                  child: Icon(
                    isIncome ? Icons.trending_up : Icons.category_outlined,
                    color: isIncome ? AppColors.teal : null,
                    size: 20,
                  ),
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        // Category Name
                        Flexible(
                          child: Text(
                            category?.name ?? (isIncome ? 'Income' : 'Expense'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Distinct Income/Expense Badge Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: isIncome
                                ? AppColors.teal.withValues(alpha: 0.15)
                                : AppColors.coral.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            isIncome ? '+ INCOME' : 'EXPENSE',
                            style: TextStyle(
                              color: isIncome
                                  ? AppColors.teal
                                  : AppColors.coral,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AmountLabel(
                amount: expense.amount,
                symbol: symbol,
                isExpense: expense.isExpense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
