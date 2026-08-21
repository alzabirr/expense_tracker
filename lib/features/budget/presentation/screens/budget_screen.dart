import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/utils/currency_formatter.dart';
import 'package:spendra/core/utils/date_utils.dart';
import 'package:spendra/core/utils/result.dart';
import 'package:spendra/core/widgets/app_button.dart';
import 'package:spendra/core/widgets/empty_state.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _amountController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentBudget = ref.read(overallBudgetProvider).valueOrNull;
      if (currentBudget != null && currentBudget.amount > 0) {
        _amountController.text = currentBudget.amount.toStringAsFixed(0);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid budget amount greater than 0.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    final result = await ref.read(budgetRepositoryProvider).saveOverallBudget(amount);
    setState(() => _isSaving = false);
    if (mounted) {
      result.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Budget saved successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        failure: (err) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save budget: ${err.message}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final budget = ref.watch(overallBudgetProvider).valueOrNull;
    final expenses =
        ref.watch(currentMonthExpensesProvider).valueOrNull ?? [];
    final currency = ref.watch(currencyCodeProvider);
    final symbol = CurrencyFormatter.symbol(currency);

    // Keep controller synced if user hasn't typed anything yet
    ref.listen(overallBudgetProvider, (prev, next) {
      final b = next.valueOrNull;
      if (b != null && _amountController.text.isEmpty) {
        _amountController.text = b.amount.toStringAsFixed(0);
      }
    });

    final spent = expenses
        .where((e) => e.isExpense)
        .fold(0.0, (s, e) => s + e.amount);
    final budgetAmount = budget?.amount ?? 0.0;
    final progress = budgetAmount > 0 ? (spent / budgetAmount).clamp(0.0, 1.0) : 0.0;

    final Color progressColor;
    if (progress >= 1.0) {
      progressColor = AppColors.danger;
    } else if (progress >= 0.8) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.coral;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Budget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current budget card
            if (budget != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: AppRadii.lgRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('This Month', style: theme.textTheme.titleMedium),
                        Text(
                          '${(progress * 100).toInt()}% used',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          '$symbol${CurrencyFormatter.formatAmount(spent)}',
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(color: AppColors.coral),
                        ),
                        Text(
                          ' / $symbol${CurrencyFormatter.formatAmount(budgetAmount)}',
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(color: textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.base),
                    ClipRRect(
                      borderRadius: AppRadii.pillRadius,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutExpo,
                        builder: (ctx, val, _) => LinearProgressIndicator(
                          value: val,
                          minHeight: 12,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceElevated
                              : AppColors.lightSurfaceElevated,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      progress >= 1.0
                          ? '⚠️ You\'ve exceeded your budget!'
                          : 'Remaining: $symbol${CurrencyFormatter.formatAmount(budgetAmount - spent)} for ${AppDateUtils.endOfMonth.difference(DateTime.now()).inDays + 1} days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: progress >= 1.0
                            ? AppColors.danger
                            : textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            Text('Set Monthly Budget', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.base),

            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter budget amount',
                prefixText: '$symbol ',
                prefixStyle: TextStyle(
                  color: AppColors.coral,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),

            AppButton(
              label: 'Save Budget',
              onPressed: _saveBudget,
              isLoading: _isSaving,
              icon: Icons.check,
            ),

            if (budget == null) ...[
              const SizedBox(height: AppSpacing.xl),
              const EmptyState(
                icon: Icons.savings_outlined,
                title: 'No budget set',
                subtitle:
                    'Set a monthly budget to track your spending progress on the Dashboard.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
