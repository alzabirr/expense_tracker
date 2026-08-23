import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/router/route_names.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/utils/currency_formatter.dart';
import 'package:spendra/core/utils/date_utils.dart';
import 'package:spendra/core/widgets/amount_display.dart';
import 'package:spendra/core/widgets/empty_state.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/category/presentation/widgets/category_chip.dart';
import 'package:spendra/features/expense/domain/entities/expense.dart';

// ── Filter State ─────────────────────────────────────────────────────────────

enum TransactionPeriod { all, thisMonth, thisWeek, today }

extension TransactionPeriodLabel on TransactionPeriod {
  String get label => switch (this) {
        TransactionPeriod.all => 'All Time',
        TransactionPeriod.thisMonth => 'This Month',
        TransactionPeriod.thisWeek => 'This Week',
        TransactionPeriod.today => 'Today',
      };
}

class _FilterState {
  const _FilterState({
    this.period = TransactionPeriod.thisMonth,
    this.searchQuery = '',
    this.categoryId,
    this.type,
  });

  final TransactionPeriod period;
  final String searchQuery;
  final String? categoryId;
  final TransactionType? type;

  _FilterState copyWith({
    TransactionPeriod? period,
    String? searchQuery,
    String? categoryId,
    bool clearCategory = false,
    TransactionType? type,
    bool clearType = false,
  }) {
    return _FilterState(
      period: period ?? this.period,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      type: clearType ? null : (type ?? this.type),
    );
  }
}

// ── Screen ───────────────────────────────────────────────────────────────────

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  _FilterState _filter = const _FilterState();
  bool _isSearchActive = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Expense> _applyFilter(List<Expense> all) {
    var result = all;

    // Period filter
    switch (_filter.period) {
      case TransactionPeriod.today:
        result = result
            .where((e) => AppDateUtils.isToday(e.date))
            .toList();
      case TransactionPeriod.thisWeek:
        final start = AppDateUtils.startOfWeek;
        result = result
            .where((e) => !e.date.isBefore(start))
            .toList();
      case TransactionPeriod.thisMonth:
        final start = AppDateUtils.startOfMonth;
        result = result
            .where((e) => !e.date.isBefore(start))
            .toList();
      case TransactionPeriod.all:
        break;
    }

    // Type filter
    if (_filter.type != null) {
      result = result.where((e) => e.type == _filter.type).toList();
    }

    // Category filter
    if (_filter.categoryId != null) {
      result = result
          .where((e) => e.categoryId == _filter.categoryId)
          .toList();
    }

    // Search
    if (_filter.searchQuery.isNotEmpty) {
      final q = _filter.searchQuery.toLowerCase();
      result = result
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              (e.merchant?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allExpenses =
        ref.watch(allExpensesStreamProvider).valueOrNull ?? [];
    final categories =
        ref.watch(categoriesStreamProvider).valueOrNull ?? [];
    final currency = ref.watch(currencyCodeProvider);
    final symbol = CurrencyFormatter.symbol(currency);

    final filtered = _applyFilter(allExpenses);
    final grouped = AppDateUtils.groupByDate(filtered, (e) => e.date);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                0,
              ),
              child: Row(
                children: [
                  // Search toggle
                  GestureDetector(
                    onTap: () => setState(() {
                      _isSearchActive = !_isSearchActive;
                      if (!_isSearchActive) {
                        _searchController.clear();
                        _filter = _filter.copyWith(searchQuery: '');
                      }
                    }),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: AppRadii.mdRadius,
                      ),
                      child: Icon(
                        _isSearchActive ? Icons.close : Icons.search,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _isSearchActive
                        ? TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: (v) => setState(
                                () => _filter =
                                    _filter.copyWith(searchQuery: v)),
                            decoration: const InputDecoration(
                              hintText: 'Search transactions...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: theme.textTheme.titleMedium,
                          )
                        : Text(
                            'Transactions',
                            style: theme.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Filter button with active dot/tint
                  GestureDetector(
                    onTap: () => _showFilterSheet(context, categories, allExpenses),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (_filter.categoryId != null || _filter.type != null)
                            ? AppColors.coral.withValues(alpha: 0.15)
                            : (isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface),
                        borderRadius: AppRadii.mdRadius,
                      ),
                      child: Icon(
                        Icons.tune,
                        color: (_filter.categoryId != null || _filter.type != null)
                            ? AppColors.coral
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Segmented Type Filter: All | Expenses | Your Income ────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.md,
                AppSpacing.base,
                0,
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _buildTypeTab(
                      label: 'All',
                      isSelected: _filter.type == null,
                      activeColor: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.08),
                      textColor: isDark
                          ? Colors.white
                          : AppColors.lightTextPrimary,
                      onTap: () => setState(() =>
                          _filter = _filter.copyWith(clearType: true)),
                    ),
                    const SizedBox(width: 4),
                    _buildTypeTab(
                      label: 'Expenses',
                      isSelected: _filter.type == TransactionType.expense,
                      activeColor: AppColors.coral.withValues(alpha: 0.18),
                      textColor: AppColors.coral,
                      onTap: () => setState(() =>
                          _filter = _filter.copyWith(type: TransactionType.expense)),
                    ),
                    const SizedBox(width: 4),
                    _buildTypeTab(
                      label: 'Your Income',
                      isSelected: _filter.type == TransactionType.income,
                      activeColor: AppColors.teal.withValues(alpha: 0.18),
                      textColor: AppColors.teal,
                      onTap: () => setState(() =>
                          _filter = _filter.copyWith(type: TransactionType.income)),
                    ),
                  ],
                ),
              ),
            ),

            // ── Period chips ────────────────────────────────────────
            SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.sm, AppSpacing.base, 0),
                scrollDirection: Axis.horizontal,
                children: TransactionPeriod.values.map((p) {
                  final isSelected = _filter.period == p;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _filter = _filter.copyWith(period: p));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.coral.withValues(alpha: 0.12)
                              : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface),
                          borderRadius: AppRadii.pillRadius,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.coral
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (isSelected) ...[
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.coral,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                            Text(
                              p.label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.coral
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── Transaction list ────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions',
                      subtitle:
                          'Try changing the filter or add a new transaction.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.base,
                        AppSpacing.sm,
                        AppSpacing.base,
                        120,
                      ),
                      children: grouped.entries.expand((entry) {
                        final date = entry.key;
                        final items = entry.value;
                        return [
                          _DateGroupHeader(date: date),
                          ...items.map((e) => _TransactionTile(
                                expense: e,
                                symbol: symbol,
                                categories: categories,
                                onDelete: () => _delete(e),
                                onEdit: () => context.push(
                                    RouteNames.editExpensePath(e.id)),
                              )),
                        ];
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? textColor
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('Delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(expenseRepositoryProvider).softDelete(expense.id);
    }
  }

  void _showFilterSheet(
    BuildContext context,
    List<Category> categories,
    List<Expense> allExpenses,
  ) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        categories: categories,
        allExpenses: allExpenses,
        selectedType: _filter.type,
        selectedCategoryId: _filter.categoryId,
        onApply: (type, categoryId) {
          setState(() {
            _filter = _filter.copyWith(
              type: type,
              clearType: type == null,
              categoryId: categoryId,
              clearCategory: categoryId == null,
            );
          });
        },
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _DateGroupHeader extends StatelessWidget {
  const _DateGroupHeader({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.base,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        AppDateUtils.groupLabelUpper(date),
        style: theme.textTheme.labelSmall?.copyWith(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.expense,
    required this.symbol,
    required this.categories,
    required this.onDelete,
    required this.onEdit,
  });

  final Expense expense;
  final String symbol;
  final List<Category> categories;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Category? cat = _allComprehensiveCategories
            .where((c) => c.id == expense.categoryId)
            .firstOrNull ??
        (categories.isEmpty
            ? null
            : categories.where((c) => c.id == expense.categoryId).firstOrNull);

    return Dismissible(
      key: Key(expense.id),
      background: _swipeBackground(
        color: AppColors.teal,
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _swipeBackground(
        color: AppColors.danger,
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        }
        onDelete();
        return false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push(RouteNames.transactionDetailPath(expense.id)),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadii.lgRadius,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  if (cat != null)
                    CategoryAvatar(category: cat)
                  else
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceElevated,
                        borderRadius: AppRadii.mdRadius,
                      ),
                      child: const Icon(Icons.category_outlined),
                    ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final String catName = cat?.name ?? (expense.isExpense ? 'Expense' : 'Income');
                        final bool isTitleSame = expense.title.trim().toLowerCase() == catName.trim().toLowerCase();

                        String subtitleText;
                        if (!isTitleSame) {
                          subtitleText = '$catName • ${expense.isExpense ? 'Expense' : 'Income'}';
                        } else if (expense.merchant != null && expense.merchant!.trim().isNotEmpty) {
                          subtitleText = '${expense.merchant!.trim()} • ${expense.isExpense ? 'Expense' : 'Income'}';
                        } else {
                          subtitleText = AppDateUtils.formatTime(expense.date);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.title,
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              subtitleText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  AmountLabel(
                    amount: expense.amount,
                    symbol: symbol,
                    isExpense: expense.isExpense,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              if (expense.note != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.attach_file, size: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        expense.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _swipeBackground({
    required Color color,
    required IconData icon,
    required AlignmentGeometry alignment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadii.lgRadius,
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Icon(icon, color: color),
    );
  }
}

const _allComprehensiveCategories = [
  // Expense
  Category(
    id: 'cat_food_grocery',
    name: 'Groceries',
    iconKey: 'shopping_basket',
    colorToken: 'amber',
  ),
  Category(
    id: 'cat_food_restaurant',
    name: 'Restaurant',
    iconKey: 'utensils',
    colorToken: 'coral',
  ),
  Category(
    id: 'cat_food_coffee',
    name: 'Coffee',
    iconKey: 'coffee',
    colorToken: 'amber',
  ),
  Category(
    id: 'cat_food_snacks',
    name: 'Snacks',
    iconKey: 'cookie',
    colorToken: 'coral',
  ),
  Category(
    id: 'cat_transport_fuel',
    name: 'Fuel',
    iconKey: 'fuel',
    colorToken: 'violet',
  ),
  Category(
    id: 'cat_transport_taxi',
    name: 'Taxi',
    iconKey: 'taxi',
    colorToken: 'violet',
  ),
  Category(
    id: 'cat_transport_transit',
    name: 'Transit',
    iconKey: 'bus',
    colorToken: 'sky',
  ),
  Category(
    id: 'cat_shopping_clothes',
    name: 'Clothes',
    iconKey: 'shirt',
    colorToken: 'pink',
  ),
  Category(
    id: 'cat_shopping_electronics',
    name: 'Gadgets',
    iconKey: 'laptop',
    colorToken: 'slate',
  ),
  Category(
    id: 'cat_shopping_accessories',
    name: 'Accessories',
    iconKey: 'watch',
    colorToken: 'rose',
  ),
  Category(
    id: 'cat_bills_rent',
    name: 'Rent',
    iconKey: 'home',
    colorToken: 'indigo',
  ),
  Category(
    id: 'cat_bills_electricity',
    name: 'Utilities',
    iconKey: 'zap',
    colorToken: 'amber',
  ),
  Category(
    id: 'cat_bills_internet',
    name: 'Internet',
    iconKey: 'wifi',
    colorToken: 'sky',
  ),
  Category(
    id: 'cat_bills_subscription',
    name: 'Subscriptions',
    iconKey: 'repeat',
    colorToken: 'indigo',
  ),
  Category(
    id: 'cat_health_medicine',
    name: 'Medicine',
    iconKey: 'pill',
    colorToken: 'red',
  ),
  Category(
    id: 'cat_health_doctor',
    name: 'Doctor',
    iconKey: 'stethoscope',
    colorToken: 'red',
  ),
  Category(
    id: 'cat_health_fitness',
    name: 'Fitness',
    iconKey: 'dumbbell',
    colorToken: 'lime',
  ),
  Category(
    id: 'cat_education_tuition',
    name: 'Education',
    iconKey: 'school',
    colorToken: 'sky',
  ),
  Category(
    id: 'cat_education_books',
    name: 'Books',
    iconKey: 'book',
    colorToken: 'sky',
  ),
  Category(
    id: 'cat_beauty_salon',
    name: 'Salon',
    iconKey: 'spa',
    colorToken: 'rose',
  ),
  Category(
    id: 'cat_family_kids',
    name: 'Kids',
    iconKey: 'family',
    colorToken: 'teal',
  ),
  Category(
    id: 'cat_pets',
    name: 'Pets',
    iconKey: 'pets',
    colorToken: 'amber',
  ),
  Category(
    id: 'cat_savings_deposit',
    name: 'Savings',
    iconKey: 'savings',
    colorToken: 'teal',
  ),
  Category(
    id: 'cat_savings_loan',
    name: 'Loan',
    iconKey: 'credit_card',
    colorToken: 'violet',
  ),
  Category(
    id: 'cat_maintenance',
    name: 'Repairs',
    iconKey: 'build',
    colorToken: 'stone',
  ),
  Category(
    id: 'cat_other_gifts',
    name: 'Gifts',
    iconKey: 'gift',
    colorToken: 'rose',
  ),
  Category(
    id: 'cat_entertainment_movies',
    name: 'Movies',
    iconKey: 'film',
    colorToken: 'teal',
  ),
  Category(
    id: 'cat_entertainment_games',
    name: 'Gaming',
    iconKey: 'gamepad',
    colorToken: 'indigo',
  ),
  Category(
    id: 'cat_entertainment_travel',
    name: 'Travel',
    iconKey: 'plane',
    colorToken: 'sky',
  ),
  Category(
    id: 'cat_other_misc',
    name: 'Other',
    iconKey: 'package',
    colorToken: 'stone',
  ),
  // Income
  Category(
    id: 'cat_income_salary',
    name: 'Salary',
    iconKey: 'banknote',
    colorToken: 'teal',
  ),
  Category(
    id: 'cat_income_freelance',
    name: 'Freelance',
    iconKey: 'briefcase',
    colorToken: 'lime',
  ),
  Category(
    id: 'cat_income_business',
    name: 'Business',
    iconKey: 'landmark',
    colorToken: 'amber',
  ),
  Category(
    id: 'cat_income_investment',
    name: 'Investments',
    iconKey: 'chart_line',
    colorToken: 'indigo',
  ),
  Category(
    id: 'cat_income_bonus',
    name: 'Bonus',
    iconKey: 'trending_up',
    colorToken: 'teal',
  ),
  Category(
    id: 'cat_income_commission',
    name: 'Commission',
    iconKey: 'receipt',
    colorToken: 'violet',
  ),
  Category(
    id: 'cat_income_rental',
    name: 'Rental',
    iconKey: 'home',
    colorToken: 'sky',
  ),
  Category(
    id: 'cat_income_dividends',
    name: 'Dividends',
    iconKey: 'savings',
    colorToken: 'teal',
  ),
  Category(
    id: 'cat_income_interest',
    name: 'Interest',
    iconKey: 'landmark',
    colorToken: 'sky',
  ),
  Category(
    id: 'cat_income_side_hustle',
    name: 'Hustle',
    iconKey: 'zap',
    colorToken: 'violet',
  ),
  Category(
    id: 'cat_income_crypto',
    name: 'Crypto',
    iconKey: 'crypto',
    colorToken: 'amber',
  ),
  Category(
    id: 'cat_income_royalty',
    name: 'Royalty',
    iconKey: 'package',
    colorToken: 'amber',
  ),
  Category(
    id: 'cat_income_cashback',
    name: 'Cashback',
    iconKey: 'sync',
    colorToken: 'sky',
  ),
  Category(
    id: 'cat_income_lottery',
    name: 'Lottery',
    iconKey: 'card_giftcard',
    colorToken: 'rose',
  ),
  Category(
    id: 'cat_income_prize',
    name: 'Prize',
    iconKey: 'card_giftcard',
    colorToken: 'amber',
  ),
  Category(
    id: 'cat_income_gift',
    name: 'Gifts',
    iconKey: 'gift',
    colorToken: 'pink',
  ),
  Category(
    id: 'cat_income_grants',
    name: 'Grants',
    iconKey: 'school',
    colorToken: 'sky',
  ),
  Category(
    id: 'cat_income_allowance',
    name: 'Allowance',
    iconKey: 'family',
    colorToken: 'rose',
  ),
  Category(
    id: 'cat_income_refund',
    name: 'Refunds',
    iconKey: 'sync',
    colorToken: 'sky',
  ),
  Category(
    id: 'cat_income_tips',
    name: 'Tips',
    iconKey: 'banknote',
    colorToken: 'teal',
  ),
  Category(
    id: 'cat_income_bribe',
    name: 'Bribe',
    iconKey: 'package',
    colorToken: 'stone',
  ),
  Category(
    id: 'cat_income_other',
    name: 'Other',
    iconKey: 'wallet',
    colorToken: 'teal',
  ),
];

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.categories,
    required this.allExpenses,
    required this.selectedType,
    required this.selectedCategoryId,
    required this.onApply,
  });

  final List<Category> categories;
  final List<Expense> allExpenses;
  final TransactionType? selectedType;
  final String? selectedCategoryId;
  final void Function(TransactionType? type, String? categoryId) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  TransactionType? _selectedType;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedCategory = widget.selectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Filter relevant expenses based on currently chosen type in the sheet
    final filteredExpenses = _selectedType == null
        ? widget.allExpenses
        : widget.allExpenses.where((e) => e.type == _selectedType).toList();

    final usedCategoryIds = filteredExpenses
        .map((e) => e.categoryId)
        .whereType<String>()
        .toSet();

    final Map<String, Category> categoryMap = {};
    for (final cat in _allComprehensiveCategories) {
      categoryMap[cat.id] = cat;
    }
    for (final cat in widget.categories) {
      categoryMap[cat.id] = cat;
    }

    final userCategories = usedCategoryIds
        .map((id) =>
            categoryMap[id] ??
            Category(
              id: id,
              name: id.replaceFirst('cat_', '').replaceAll('_', ' ').toUpperCase(),
              iconKey: 'more_horizontal',
              colorToken: 'coral',
            ))
        .toList();

    final allCats = userCategories.isNotEmpty
        ? userCategories
        : (_selectedType == TransactionType.income
            ? _allComprehensiveCategories
                .where((c) => c.id.startsWith('cat_income'))
                .toList()
            : (_selectedType == TransactionType.expense
                ? _allComprehensiveCategories
                    .where((c) => !c.id.startsWith('cat_income'))
                    .toList()
                : _allComprehensiveCategories));

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.base),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Category',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (_selectedCategory != null || _selectedType != null)
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedType = null;
                        _selectedCategory = null;
                      }),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              // ── Type Toggle (All, Expenses, Your Income) ───────────
              Text(
                'TYPE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: textSecondary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _typeTab(
                      label: 'All',
                      isSelected: _selectedType == null,
                      activeColor: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.08),
                      textColor: isDark
                          ? Colors.white
                          : AppColors.lightTextPrimary,
                      onTap: () => setState(() {
                        _selectedType = null;
                        _selectedCategory = null;
                      }),
                    ),
                    const SizedBox(width: 4),
                    _typeTab(
                      label: 'Expenses',
                      isSelected: _selectedType == TransactionType.expense,
                      activeColor: AppColors.coral.withValues(alpha: 0.18),
                      textColor: AppColors.coral,
                      onTap: () => setState(() {
                        _selectedType = TransactionType.expense;
                        _selectedCategory = null;
                      }),
                    ),
                    const SizedBox(width: 4),
                    _typeTab(
                      label: 'Your Income',
                      isSelected: _selectedType == TransactionType.income,
                      activeColor: AppColors.teal.withValues(alpha: 0.18),
                      textColor: AppColors.teal,
                      onTap: () => setState(() {
                        _selectedType = TransactionType.income;
                        _selectedCategory = null;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // ── Category Header ──────────────────────────────────
              Text(
                'CATEGORY',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: textSecondary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.38,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _selectedCategory = null),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedCategory == null
                                ? AppColors.coral.withValues(alpha: 0.15)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.04)),
                            borderRadius: AppRadii.pillRadius,
                            border: Border.all(
                              color: _selectedCategory == null
                                  ? AppColors.coral
                                  : (isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightDivider),
                            ),
                          ),
                          child: Text(
                            'All Categories',
                            style: TextStyle(
                              color: _selectedCategory == null
                                  ? AppColors.coral
                                  : textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      ...allCats.map((cat) => CategoryChip(
                            category: cat,
                            isSelected: _selectedCategory == cat.id,
                            onTap: () => setState(() => _selectedCategory = cat.id),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedType, _selectedCategory);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Filter',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeTab({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? textColor
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
