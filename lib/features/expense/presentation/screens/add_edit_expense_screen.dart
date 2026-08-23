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

  bool get isValid => amount > 0;

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

// ── Default Categories ────────────────────────────────────────────────────────
const defaultExpenseCategories = [
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
];

const defaultIncomeCategories = [
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
    _form = _form.copyWith(
      date: DateTime.now(),
      selectedCategoryId: 'cat_food_grocery',
    );
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
        final cleanAmount = expense.amount == expense.amount.roundToDouble()
            ? expense.amount.toInt().toString()
            : expense.amount.toString();
        setState(() {
          _form = _ExpenseFormState(
            amount: expense.amount,
            rawInput: cleanAmount,
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
        current =
            current.isEmpty ? '0' : current.substring(0, current.length - 1);
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

    final repo = ref.read(expenseRepositoryProvider);
    final customCats = ref.read(categoriesStreamProvider).valueOrNull ?? [];
    final allCats = [
      ...defaultExpenseCategories,
      ...defaultIncomeCategories,
      ...customCats
    ];
    final cat =
        allCats.where((c) => c.id == _form.selectedCategoryId).firstOrNull;

    final allExpenses = ref.read(allExpensesStreamProvider).valueOrNull ?? [];

    // Calculate baseline balance excluding the current item being edited
    final baseIncome = allExpenses
        .where((e) => e.isIncome && e.id != widget.editId)
        .fold(0.0, (s, e) => s + e.amount);
    final baseSpent = allExpenses
        .where((e) => e.isExpense && e.id != widget.editId)
        .fold(0.0, (s, e) => s + e.amount);
    final effectiveAvailableBalance = baseIncome - baseSpent;

    final currency = ref.read(currencyCodeProvider);
    final symbol = CurrencyFormatter.symbol(currency);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Block if Insufficient Balance when spending ──────────────────────────
    if (_form.type == TransactionType.expense) {
      if (effectiveAvailableBalance <= 0 ||
          _form.amount > effectiveAvailableBalance) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    color: Colors.redAccent, size: 24),
                SizedBox(width: 8),
                Text('Insufficient Balance',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'You do not have enough balance for this expense.\n\nAvailable Balance: $symbol${CurrencyFormatter.formatAmount(effectiveAvailableBalance.clamp(0, double.infinity))}\nExpense Amount: $symbol${CurrencyFormatter.formatAmount(_form.amount)}\n\nPlease add income first.',
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _form = _form.copyWith(
                      type: TransactionType.income,
                      selectedCategoryId: 'cat_income_salary'));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('+ Add Income'),
              ),
            ],
          ),
        );
        return;
      }
    }

    HapticFeedback.mediumImpact();
    setState(() => _form = _form.copyWith(isSaving: true));

    final now = DateTime.now();
    final txDate = _form.date != null
        ? DateTime(
            _form.date!.year,
            _form.date!.month,
            _form.date!.day,
            now.hour,
            now.minute,
            now.second,
            now.millisecond,
          )
        : now;

    final expense = Expense(
      id: widget.editId ?? const Uuid().v4(),
      title: _form.title.isNotEmpty
          ? _form.title
          : (cat?.name ??
              (_form.type == TransactionType.expense ? 'Expense' : 'Income')),
      amount: _form.amount,
      categoryId: _form.selectedCategoryId ??
          (_form.type == TransactionType.expense
              ? 'cat_food_grocery'
              : 'cat_income_salary'),
      type: _form.type,
      date: txDate,
      createdAt: widget.editId != null ? (_form.createdAt ?? now) : now,
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

        final remainingBalance = _form.type == TransactionType.expense
            ? effectiveAvailableBalance - _form.amount
            : effectiveAvailableBalance + _form.amount;

        final isLowBalance = _form.type == TransactionType.expense &&
            remainingBalance >= 0 &&
            (remainingBalance <= (baseIncome * 0.15).clamp(10.0, 500.0) ||
                remainingBalance <= 20.0);

        if (isLowBalance) {
          // ── Warning: Low Balance Pop-up ──────────────────────────────────
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your balance is low!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Remaining Balance: $symbol${CurrencyFormatter.formatAmount(remainingBalance)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFC88A2E),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(),
            ),
          );
        } else {
          // ── Standard Success SnackBar ────────────────────────────────────
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
                    widget.editId != null
                        ? 'Transaction updated'
                        : (_form.type == TransactionType.expense
                            ? 'Expense saved!'
                            : 'Income saved!'),
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
        }
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
    final isExpense = _form.type == TransactionType.expense;
    final currency = ref.watch(currencyCodeProvider);
    final symbol = CurrencyFormatter.symbol(currency);
    int catTime(Category c) {
      if (c.sortOrder > 0) return c.sortOrder;
      final numMatch = RegExp(r'(\d+)').firstMatch(c.id);
      if (numMatch != null) return int.tryParse(numMatch.group(1)!) ?? 0;
      return 0;
    }

    final customCategories = (ref.watch(categoriesStreamProvider).valueOrNull ??
            [])
        .where((c) => !c.isDefault)
        .toList()
      ..sort((a, b) {
        final tA = catTime(a);
        final tB = catTime(b);
        if (tA != tB) return tB.compareTo(tA);
        return b.id.compareTo(a.id);
      });
    final customExpenseCategories = customCategories
        .where((c) => c.parentId != 'cat_income' && !c.id.contains('_inc_'))
        .toList();
    final customIncomeCategories = customCategories
        .where((c) => c.parentId == 'cat_income' || c.id.contains('_inc_'))
        .toList();

    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final activeCategories = _form.type == TransactionType.expense
        ? [...customExpenseCategories, ...defaultExpenseCategories]
        : [...customIncomeCategories, ...defaultIncomeCategories];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
                      child: const Icon(Icons.close,
                          color: AppColors.teal, size: 18),
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
                                selectedCategoryId: 'cat_food_grocery',
                              )),
                        ),
                        _TypeToggle(
                          label: 'Income',
                          isSelected: _form.type == TransactionType.income,
                          color: AppColors.teal,
                          onTap: () => setState(() => _form = _form.copyWith(
                                type: TransactionType.income,
                                selectedCategoryId: 'cat_income_salary',
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
                      // Category Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CATEGORY',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                _showAddCustomCategorySheet(context, isDark),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 14,
                                  color: isExpense
                                      ? AppColors.coral
                                      : AppColors.teal,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Add Category',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isExpense
                                        ? AppColors.coral
                                        : AppColors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 260,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 8,
                            children: [
                              ...activeCategories.map((cat) {
                                return CategoryChip(
                                  category: cat,
                                  isSelected:
                                      _form.selectedCategoryId == cat.id,
                                  onTap: () => setState(
                                    () => _form = _form.copyWith(
                                      selectedCategoryId: cat.id,
                                    ),
                                  ),
                                );
                              }),
                            ],
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
                label: widget.editId != null
                    ? 'Update'
                    : (_form.type == TransactionType.expense
                        ? 'Save Expense'
                        : 'Save Income'),
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

  void _showAddCustomCategorySheet(BuildContext context, bool isDark) {
    final nameCtrl = TextEditingController();
    String selectedColor =
        _form.type == TransactionType.expense ? 'coral' : 'teal';
    String? selectedIcon;
    String? selectedParentId;

    const iconChoices = [
      // Food & Dining
      ('utensils', Icons.restaurant),
      ('coffee', Icons.coffee),
      ('pizza', Icons.local_pizza),
      ('burger', Icons.lunch_dining),
      ('cookie', Icons.cookie),
      ('ice_cream', Icons.icecream),
      ('drink', Icons.local_bar),
      ('wine', Icons.wine_bar),
      ('cake', Icons.cake),
      ('fastfood', Icons.fastfood),
      ('apple', Icons.apple),
      ('egg', Icons.egg),
      ('ramen', Icons.ramen_dining),
      ('rice', Icons.rice_bowl),
      ('kebab', Icons.kebab_dining),
      ('breakfast', Icons.free_breakfast),
      ('shopping_basket', Icons.shopping_basket),

      // Shopping & Fashion
      ('shopping_bag', Icons.shopping_bag),
      ('shopping_cart', Icons.shopping_cart),
      ('store', Icons.storefront),
      ('shirt', Icons.checkroom),
      ('watch', Icons.watch),
      ('diamond', Icons.diamond),
      ('gift', Icons.card_giftcard),
      ('package', Icons.inventory_2),
      ('scissors', Icons.content_cut),
      ('brush', Icons.brush),
      ('palette', Icons.palette),
      ('local_offer', Icons.local_offer),
      ('sell', Icons.sell),
      ('dry_cleaning', Icons.dry_cleaning),

      // Transport & Travel
      ('car', Icons.directions_car),
      ('fuel', Icons.local_gas_station),
      ('taxi', Icons.local_taxi),
      ('bus', Icons.directions_bus),
      ('motorcycle', Icons.two_wheeler),
      ('bicycle', Icons.pedal_bike),
      ('electric_scooter', Icons.electric_scooter),
      ('electric_car', Icons.electric_car),
      ('train', Icons.train),
      ('subway', Icons.subway),
      ('boat', Icons.directions_boat),
      ('plane', Icons.flight),
      ('luggage', Icons.luggage),
      ('hotel', Icons.hotel),
      ('parking', Icons.local_parking),
      ('rocket', Icons.rocket_launch),
      ('map', Icons.map),

      // Home, Living & Bills
      ('receipt', Icons.receipt_long),
      ('home', Icons.home),
      ('apartment', Icons.apartment),
      ('wifi', Icons.wifi),
      ('zap', Icons.bolt),
      ('water', Icons.water_drop),
      ('repeat', Icons.repeat),
      ('clean', Icons.cleaning_services),
      ('laundry', Icons.local_laundry_service),
      ('build', Icons.build),
      ('handyman', Icons.handyman),
      ('yard', Icons.yard),
      ('kitchen', Icons.kitchen),
      ('bed', Icons.bed),
      ('chair', Icons.chair),
      ('ac_unit', Icons.ac_unit),
      ('solar_power', Icons.solar_power),

      // Health & Fitness
      ('heart', Icons.favorite),
      ('pill', Icons.medication),
      ('stethoscope', Icons.medical_services),
      ('hospital', Icons.local_hospital),
      ('dumbbell', Icons.fitness_center),
      ('run', Icons.directions_run),
      ('pool', Icons.pool),
      ('spa', Icons.spa),
      ('self_improvement', Icons.self_improvement),
      ('sports_tennis', Icons.sports_tennis),
      ('sports_golf', Icons.sports_golf),
      ('sports_volleyball', Icons.sports_volleyball),
      ('hiking', Icons.hiking),

      // Tech & Entertainment
      ('laptop', Icons.laptop),
      ('smartphone', Icons.smartphone),
      ('tv', Icons.tv),
      ('headphones', Icons.headphones),
      ('music', Icons.music_note),
      ('mic', Icons.mic),
      ('piano', Icons.piano),
      ('camera', Icons.camera_alt),
      ('videocam', Icons.videocam),
      ('film', Icons.movie),
      ('gamepad', Icons.sports_esports),
      ('sports_soccer', Icons.sports_soccer),
      ('sports_cricket', Icons.sports_cricket),
      ('sports_basketball', Icons.sports_basketball),
      ('celebration', Icons.celebration),
      ('casino', Icons.casino),
      ('code', Icons.code),
      ('cloud', Icons.cloud),

      // Education, Family & Nature
      ('school', Icons.school),
      ('book', Icons.menu_book),
      ('child_care', Icons.child_care),
      ('child_friendly', Icons.child_friendly),
      ('toys', Icons.toys),
      ('family', Icons.family_restroom),
      ('pets', Icons.pets),
      ('forest', Icons.forest),
      ('park', Icons.park),
      ('science', Icons.science),

      // Income & Finance
      ('banknote', Icons.payments),
      ('briefcase', Icons.work),
      ('landmark', Icons.account_balance),
      ('credit_card', Icons.credit_card),
      ('chart_line', Icons.show_chart),
      ('trending_up', Icons.trending_up),
      ('savings', Icons.savings),
      ('crypto', Icons.currency_bitcoin),
      ('wallet', Icons.account_balance_wallet),
      ('calculate', Icons.calculate),
      ('gold', Icons.monetization_on),
      ('paid', Icons.paid),
      ('request_quote', Icons.request_quote),
      ('gavel', Icons.gavel),
      ('handshake', Icons.handshake),
      ('volunteer_activism', Icons.volunteer_activism),
      ('bribe', Icons.privacy_tip),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final theme = Theme.of(context);
          final activeThemeColor = _form.type == TransactionType.expense
              ? AppColors.coral
              : AppColors.teal;

          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.xl,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New ${_form.type == TransactionType.expense ? "Expense" : "Income"} Category',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Category Name (e.g. Snacks, Gym, Tuition)',
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceElevated
                          : AppColors.lightSurfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'SELECT ICON',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 140,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: iconChoices.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (context, idx) {
                        final item = iconChoices[idx];
                        final isSelected = item.$1 == selectedIcon;
                        return GestureDetector(
                          onTap: () =>
                              setSheetState(() => selectedIcon = item.$1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activeThemeColor.withValues(alpha: 0.2)
                                  : (isDark
                                      ? AppColors.darkSurfaceElevated
                                      : AppColors.lightSurfaceElevated),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? activeThemeColor
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              item.$2,
                              size: 20,
                              color: isSelected
                                  ? activeThemeColor
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'SELECT COLOR',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppColors.categoryPalette.entries.map((e) {
                      final isSelected = e.key == selectedColor;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedColor = e.key),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: e.value,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2.5)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;

                        final isExpense = _form.type == TransactionType.expense;
                        final newCat = Category(
                          id: 'cat_custom_${isExpense ? "exp" : "inc"}_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          iconKey: selectedIcon ??
                              (isExpense ? 'shopping_bag' : 'banknote'),
                          colorToken: selectedColor,
                          parentId: isExpense ? 'cat_expense' : 'cat_income',
                          isDefault: false,
                          sortOrder:
                              DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        );

                        await ref.read(categoryRepositoryProvider).add(newCat);

                        if (mounted) {
                          setState(() {
                            _form =
                                _form.copyWith(selectedCategoryId: newCat.id);
                          });
                        }

                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeThemeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Save & Select Category',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
