import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/utils/currency_formatter.dart';
import 'package:spendra/core/utils/result.dart';
import 'package:spendra/core/widgets/app_button.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/category/presentation/widgets/category_chip.dart';
import 'package:spendra/features/expense/domain/entities/expense.dart';

// ── Form State ───────────────────────────────────────────────────────────────

class _ExpenseFormState {
  const _ExpenseFormState({
    this.amount = 0,
    this.rawInput = '0',
    this.type = TransactionType.expense,
    this.selectedCategoryId,
    this.title = '',
    this.merchant = '',
    this.note = '',
    this.date,
    this.createdAt,
    this.paymentMethod = PaymentMethod.cash,
    this.isSaving = false,
  });

  final double amount;
  final String rawInput;
  final TransactionType type;
  final String? selectedCategoryId;
  final String title;
  final String merchant;
  final String note;
  final DateTime? date;
  final DateTime? createdAt;
  final PaymentMethod paymentMethod;
  final bool isSaving;

  bool get isValid => amount > 0 && selectedCategoryId != null;

  _ExpenseFormState copyWith({
    double? amount,
    String? rawInput,
    TransactionType? type,
    String? selectedCategoryId,
    String? title,
    String? merchant,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    PaymentMethod? paymentMethod,
    bool? isSaving,
  }) {
    return _ExpenseFormState(
      amount: amount ?? this.amount,
      rawInput: rawInput ?? this.rawInput,
      type: type ?? this.type,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      title: title ?? this.title,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

// ── Screen ───────────────────────────────────────────────────────────────────

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  const AddEditExpenseScreen({super.key, this.editId});

  final String? editId;

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  _ExpenseFormState _form = const _ExpenseFormState();
  final _titleController = TextEditingController();
  final _merchantController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _form = _form.copyWith(date: DateTime.now());
    if (widget.editId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEdit());
    }
  }

  Future<void> _loadEdit() async {
    final repo = ref.read(expenseRepositoryProvider);
    final result = await repo.getById(widget.editId!);
    if (!mounted) return;
    result.when(
      success: (expense) {
        _titleController.text = expense.title;
        _merchantController.text = expense.merchant ?? '';
        _noteController.text = expense.note ?? '';
        setState(() {
          _form = _ExpenseFormState(
            amount: expense.amount,
            rawInput: expense.amount.toStringAsFixed(2),
            type: expense.type,
            selectedCategoryId: expense.categoryId,
            title: expense.title,
            merchant: expense.merchant ?? '',
            note: expense.note ?? '',
            date: expense.date,
            createdAt: expense.createdAt,
            paymentMethod: expense.paymentMethod,
          );
        });
      },
      failure: (_) {},
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onKeypad(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      String current = _form.rawInput == '0' ? '' : _form.rawInput;
      if (key == 'DEL') {
        current = current.isEmpty ? '0' : current.substring(0, current.length - 1);
        if (current.isEmpty) {
          current = '0';
        }
      } else if (key == '.') {
        if (!current.contains('.')) {
          current += '.';
        }
      } else {
        if (current == '0') {
          current = key;
        } else {
          current += key;
        }
      }
      final amount = double.tryParse(current) ?? 0;
      _form = _form.copyWith(rawInput: current, amount: amount);
    });
  }

  Future<void> _save() async {
    if (!_form.isValid) return;

    bool isLowBalance = false;

    // Check if expense amount exceeds total available balance
    if (_form.type == TransactionType.expense) {
      final summary = ref.read(dashboardSummaryProvider);
      double availableBalance = summary.totalBalance;
      if (widget.editId != null) {
        final all = ref.read(allExpensesStreamProvider).valueOrNull ?? [];
        final old = all.where((e) => e.id == widget.editId).firstOrNull;
        if (old != null && old.isExpense) {
          availableBalance += old.amount;
        }
      }

      if (_form.amount > availableBalance) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final symbol = CurrencyFormatter.symbol(ref.read(currencyCodeProvider));
        final formattedAvail = CurrencyFormatter.formatAmount(
            availableBalance < 0 ? 0 : availableBalance);

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor:
                isDark ? const Color(0xFF1E2126) : AppColors.lightSurface,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.lgRadius),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.coral, size: 28),
                SizedBox(width: 10),
                Text(
                  'Insufficient Balance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: Text(
              'Your expense amount exceeds your available balance ($symbol $formattedAvail). You cannot add this expense.',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                      color: AppColors.coral,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ],
          ),
        );
        return;
      }

      // Calculate if balance is low after this expense (<= 10% of total income)
      final remainingAfterExpense = availableBalance - _form.amount;
      final totalIncome = summary.totalIncome;
      isLowBalance = (totalIncome > 0 && remainingAfterExpense <= totalIncome * 0.10) ||
          (totalIncome == 0 && remainingAfterExpense <= 10);
    }

    HapticFeedback.mediumImpact();
    setState(() => _form = _form.copyWith(isSaving: true));

    final repo = ref.read(expenseRepositoryProvider);
    final categories = ref.read(categoriesStreamProvider).valueOrNull ?? [];
    final cat = categories.where((c) => c.id == _form.selectedCategoryId).firstOrNull;

    final now = DateTime.now();
    final expense = Expense(
      id: widget.editId ?? const Uuid().v4(),
      title: _form.title.isNotEmpty
          ? _form.title
          : (cat?.name ?? 'Transaction'),
      amount: _form.amount,
      categoryId: _form.selectedCategoryId!,
      type: _form.type,
      date: _form.date ?? now,
      createdAt: _form.createdAt ?? now,
      updatedAt: now,
      merchant: _form.merchant.isEmpty ? null : _form.merchant,
      note: _form.note.isEmpty ? null : _form.note,
      paymentMethod: _form.paymentMethod,
    );

    final result = widget.editId != null
        ? await repo.update(expense)
        : await repo.add(expense);

    if (!mounted) return;
    result.when(
      success: (_) {
        context.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  _form.type == TransactionType.expense
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isLowBalance
                      ? 'Expense saved! ⚠️ Low Balance Alert'
                      : (widget.editId != null
                          ? 'Transaction updated'
                          : (_form.type == TransactionType.expense
                              ? 'Expense saved!'
                              : 'Income saved!')),
                ),
              ],
            ),
            backgroundColor: _form.type == TransactionType.expense
                ? AppColors.coral
                : AppColors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.mdRadius,
            ),
          ),
        );
      },
      failure: (err) {
        setState(() => _form = _form.copyWith(isSaving: false));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = ref.watch(currencyCodeProvider);
    final symbol = CurrencyFormatter.symbol(currency);
    final customCategories =
        (ref.watch(categoriesStreamProvider).valueOrNull ?? [])
            .where((c) => !c.isDefault)
            .toList();
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    // Rich default categories for Expense
    const defaultExpenseCategories = [
      Category(
        id: 'cat_food',
        name: 'Food & Dining',
        iconKey: 'utensils',
        colorToken: 'coral',
      ),
      Category(
        id: 'cat_food_grocery',
        name: 'Groceries',
        iconKey: 'shopping_basket',
        colorToken: 'amber',
      ),
      Category(
        id: 'cat_food_coffee',
        name: 'Coffee & Snacks',
        iconKey: 'coffee',
        colorToken: 'amber',
      ),
      Category(
        id: 'cat_transport',
        name: 'Transport',
        iconKey: 'car',
        colorToken: 'violet',
      ),
      Category(
        id: 'cat_transport_fuel',
        name: 'Fuel / Gas',
        iconKey: 'fuel',
        colorToken: 'violet',
      ),
      Category(
        id: 'cat_shopping',
        name: 'Shopping',
        iconKey: 'shopping_bag',
        colorToken: 'pink',
      ),
      Category(
        id: 'cat_shopping_clothes',
        name: 'Clothes',
        iconKey: 'shirt',
        colorToken: 'pink',
      ),
      Category(
        id: 'cat_shopping_electronics',
        name: 'Electronics',
        iconKey: 'laptop',
        colorToken: 'slate',
      ),
      Category(
        id: 'cat_bills',
        name: 'Bills & Utilities',
        iconKey: 'receipt',
        colorToken: 'slate',
      ),
      Category(
        id: 'cat_bills_rent',
        name: 'Rent & Housing',
        iconKey: 'home',
        colorToken: 'indigo',
      ),
      Category(
        id: 'cat_health',
        name: 'Health & Medical',
        iconKey: 'heart',
        colorToken: 'red',
      ),
      Category(
        id: 'cat_health_fitness',
        name: 'Fitness & Gym',
        iconKey: 'dumbbell',
        colorToken: 'lime',
      ),
      Category(
        id: 'cat_entertainment',
        name: 'Entertainment',
        iconKey: 'film',
        colorToken: 'teal',
      ),
      Category(
        id: 'cat_entertainment_travel',
        name: 'Travel & Vacation',
        iconKey: 'plane',
        colorToken: 'sky',
      ),
      Category(
        id: 'cat_other_education',
        name: 'Education',
        iconKey: 'school',
        colorToken: 'sky',
      ),
      Category(
        id: 'cat_beauty',
        name: 'Personal Care',
        iconKey: 'spa',
        colorToken: 'rose',
      ),
      Category(
        id: 'cat_family',
        name: 'Family & Kids',
        iconKey: 'family',
        colorToken: 'teal',
      ),
      Category(
        id: 'cat_savings',
        name: 'Savings & Invest',
        iconKey: 'savings',
        colorToken: 'teal',
      ),
      Category(
        id: 'cat_pets',
        name: 'Pets',
        iconKey: 'pets',
        colorToken: 'amber',
      ),
      Category(
        id: 'cat_other_gifts',
        name: 'Gifts & Donations',
        iconKey: 'gift',
        colorToken: 'rose',
      ),
      Category(
        id: 'cat_other_misc',
        name: 'Miscellaneous',
        iconKey: 'package',
        colorToken: 'stone',
      ),
    ];

    // Rich default categories for Income
    const defaultIncomeCategories = [
      Category(
        id: 'cat_income_salary',
        name: 'Salary / Job',
        iconKey: 'banknote',
        colorToken: 'teal',
      ),
      Category(
        id: 'cat_income_freelance',
        name: 'Freelance / Projects',
        iconKey: 'briefcase',
        colorToken: 'lime',
      ),
      Category(
        id: 'cat_income_business',
        name: 'Business / Sales',
        iconKey: 'landmark',
        colorToken: 'amber',
      ),
      Category(
        id: 'cat_income_investment',
        name: 'Investments & Stocks',
        iconKey: 'chart_line',
        colorToken: 'indigo',
      ),
      Category(
        id: 'cat_income_bonus',
        name: 'Bonus & Commission',
        iconKey: 'trending_up',
        colorToken: 'teal',
      ),
      Category(
        id: 'cat_income_rental',
        name: 'Rental Income',
        iconKey: 'home',
        colorToken: 'sky',
      ),
      Category(
        id: 'cat_income_side_hustle',
        name: 'Side Hustle',
        iconKey: 'zap',
        colorToken: 'violet',
      ),
      Category(
        id: 'cat_income_crypto',
        name: 'Crypto / Trading',
        iconKey: 'crypto',
        colorToken: 'amber',
      ),
      Category(
        id: 'cat_income_gift',
        name: 'Gifts & Grants',
        iconKey: 'gift',
        colorToken: 'pink',
      ),
      Category(
        id: 'cat_income_allowance',
        name: 'Allowance / Pocket',
        iconKey: 'family',
        colorToken: 'rose',
      ),
      Category(
        id: 'cat_income_refund',
        name: 'Refunds & Cashback',
        iconKey: 'sync',
        colorToken: 'sky',
      ),
      Category(
        id: 'cat_income_other',
        name: 'Other Income',
        iconKey: 'wallet',
        colorToken: 'teal',
      ),
    ];

    final activeCategories = _form.type == TransactionType.expense
        ? [...defaultExpenseCategories, ...customCategories]
        : [...defaultIncomeCategories, ...customCategories];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: AppColors.teal, size: 18),
                    ),
                  ),
                  const Spacer(),
                  // Type toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: AppRadii.pillRadius,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TypeToggle(
                          label: 'Expense',
                          isSelected: _form.type == TransactionType.expense,
                          color: AppColors.coral,
                          onTap: () => setState(() => _form = _form.copyWith(
                                type: TransactionType.expense,
                                selectedCategoryId: null,
                              )),
                        ),
                        _TypeToggle(
                          label: 'Income',
                          isSelected: _form.type == TransactionType.income,
                          color: AppColors.teal,
                          onTap: () => setState(() => _form = _form.copyWith(
                                type: TransactionType.income,
                                selectedCategoryId: null,
                              )),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ── Amount Display ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                children: [
                  Text(
                    'ENTER AMOUNT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          symbol,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: _form.type == TransactionType.expense
                                ? AppColors.coral
                                : AppColors.teal,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _form.rawInput,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 52,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Scrollable form area ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  0,
                  AppSpacing.base,
                  AppSpacing.base,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: AppRadii.xlRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Text(
                        'CATEGORY',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 260,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 8,
                            children: activeCategories.map((cat) {
                              return CategoryChip(
                                category: cat,
                                isSelected: _form.selectedCategoryId == cat.id,
                                onTap: () => setState(
                                  () => _form = _form.copyWith(
                                    selectedCategoryId: cat.id,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),

            // ── Keypad ───────────────────────────────────────────────
            _NumKeypad(onKey: _onKeypad),

            // ── Save Button ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.sm,
                AppSpacing.base,
                AppSpacing.base,
              ),
              child: AppButton(
                label: widget.editId != null ? 'Update' : 'Save Expense',
                onPressed: _form.isValid ? _save : null,
                isLoading: _form.isSaving,
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: AppRadii.pillRadius,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.darkTextSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}


class _NumKeypad extends StatelessWidget {
  const _NumKeypad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', 'DEL'],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: _keys.map((row) {
          return Row(
            children: row.map((key) {
              return Expanded(
                child: AspectRatio(
                  aspectRatio: 2.5,
                  child: GestureDetector(
                    onTap: () => onKey(key),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.lightSurfaceElevated,
                        borderRadius: AppRadii.mdRadius,
                      ),
                      child: Center(
                        child: key == 'DEL'
                            ? Icon(
                                Icons.backspace_outlined,
                                size: 20,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              )
                            : Text(
                                key,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
