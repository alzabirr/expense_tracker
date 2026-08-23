import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/router/route_names.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/utils/currency_formatter.dart';
import 'package:spendra/core/utils/date_utils.dart';
import 'package:spendra/core/widgets/app_button.dart';
import 'package:spendra/features/category/presentation/widgets/category_chip.dart';
import 'package:spendra/features/expense/domain/entities/expense.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allExpenses = ref.watch(allExpensesStreamProvider).valueOrNull ?? [];
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? [];
    final currency = ref.watch(currencyCodeProvider);
    final symbol = CurrencyFormatter.symbol(currency);

    final Expense? expense = allExpenses
        .where((e) => e.id == transactionId)
        .firstOrNull;

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final cat = categories.where((c) => c.id == expense.categoryId).firstOrNull;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final color = expense.isExpense ? AppColors.coral : AppColors.teal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(RouteNames.editExpensePath(expense.id)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          children: [
            // Amount hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: AppRadii.xlRadius,
              ),
              child: Column(
                children: [
                  if (cat != null) CategoryAvatar(category: cat, size: 60),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    expense.title,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  if (expense.merchant != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      expense.merchant!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: textSecondary),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    '${expense.isExpense ? '-' : '+'}$symbol ${CurrencyFormatter.formatAmount(expense.amount)}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: AppRadii.pillRadius,
                    ),
                    child: Text(
                      expense.isExpense ? 'Expense' : 'Income',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            // Details
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: AppRadii.lgRadius,
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: AppDateUtils.formatFull(expense.date),
                  ),
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    value: AppDateUtils.formatTime(expense.date),
                  ),
                  if (expense.merchant != null &&
                      expense.merchant!.trim().isNotEmpty)
                    _DetailRow(
                      icon: Icons.storefront_outlined,
                      label: 'Merchant / Place',
                      value: expense.merchant!,
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            // Note Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.base),
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
                      Row(
                        children: [
                          Icon(Icons.description_outlined,
                              size: 18, color: color),
                          const SizedBox(width: 8),
                          Text(
                            'Note',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () =>
                            _editNoteDialog(context, ref, expense, isDark),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                (expense.note != null &&
                                        expense.note!.trim().isNotEmpty)
                                    ? Icons.edit
                                    : Icons.add,
                                size: 13,
                                color: color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (expense.note != null &&
                                        expense.note!.trim().isNotEmpty)
                                    ? 'Edit'
                                    : 'Add Note',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (expense.note != null && expense.note!.trim().isNotEmpty)
                    Text(
                      expense.note!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    )
                  else
                    Text(
                      'No note added for this transaction.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            AppButton(
              label: 'Delete Transaction',
              variant: AppButtonVariant.danger,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete?'),
                    content: Text('Delete "${expense.title}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref
                      .read(expenseRepositoryProvider)
                      .softDelete(expense.id);
                  if (context.mounted) context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editNoteDialog(
      BuildContext context, WidgetRef ref, Expense expense, bool isDark) {
    final noteCtrl = TextEditingController(text: expense.note ?? '');
    final color = expense.isExpense ? AppColors.coral : AppColors.teal;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bg =
        isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.base,
          right: AppSpacing.base,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_note, color: color, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Transaction Note',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (expense.note != null && expense.note!.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(expenseRepositoryProvider)
                          .update(expense.copyWith(note: null));
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Clear',
                        style: TextStyle(color: AppColors.danger)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: TextField(
                controller: noteCtrl,
                autofocus: true,
                maxLines: 3,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Type your note or memo here...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final text = noteCtrl.text.trim();
                  await ref.read(expenseRepositoryProvider).update(
                      expense.copyWith(note: text.isEmpty ? null : text));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Note',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.coral, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: textSecondary),
                ),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
