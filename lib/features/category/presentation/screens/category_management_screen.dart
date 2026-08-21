import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/widgets/empty_state.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/category/presentation/widgets/category_chip.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categories =
        ref.watch(categoriesStreamProvider).valueOrNull ?? [];
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final topLevel = categories.where((c) => c.isTopLevel).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSheet(context, ref),
          ),
        ],
      ),
      body: topLevel.isEmpty
          ? const EmptyState(
              icon: Icons.category_outlined,
              title: 'No categories',
              subtitle: 'Tap + to create your first category.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, AppSpacing.sm, AppSpacing.base, 120),
              itemCount: topLevel.length,
              itemBuilder: (context, i) {
                final cat = topLevel[i];
                final children = categories
                    .where((c) => c.parentId == cat.id)
                    .toList();
                return _CategoryCard(
                  category: cat,
                  children: children,
                  surface: surface,
                  textSecondary: textSecondary,
                  onArchive: cat.isDefault
                      ? null
                      : () => ref
                          .read(categoryRepositoryProvider)
                          .archive(cat.id),
                );
              },
            ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    String selectedColor = 'coral';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Category',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.base),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration:
                    const InputDecoration(hintText: 'Category name'),
              ),
              const SizedBox(height: AppSpacing.base),
              Text('Color',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.8,
                      )),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: AppColors.categoryPalette.entries.map((e) {
                  final isSelected = e.key == selectedColor;
                  return GestureDetector(
                    onTap: () =>
                        setSheetState(() => selectedColor = e.key),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: e.value,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Colors.white, width: 2.5)
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
                    if (nameCtrl.text.trim().isEmpty) return;
                    final cat = Category(
                      id: const Uuid().v4(),
                      name: nameCtrl.text.trim(),
                      iconKey: 'package',
                      colorToken: selectedColor,
                      isDefault: false,
                    );
                    await ref
                        .read(categoryRepositoryProvider)
                        .add(cat);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Create',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.children,
    required this.surface,
    required this.textSecondary,
    this.onArchive,
  });

  final Category category;
  final List<Category> children;
  final Color surface;
  final Color textSecondary;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.fromToken(category.colorToken);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadii.lgRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryAvatar(category: category),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name,
                        style: theme.textTheme.titleMedium),
                    Text(
                      '${children.length} subcategories',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: textSecondary),
                    ),
                  ],
                ),
              ),
              if (category.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppRadii.pillRadius,
                  ),
                  child: Text(
                    'Default',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (onArchive != null)
                IconButton(
                  icon: const Icon(Icons.archive_outlined, size: 20),
                  color: textSecondary,
                  onPressed: onArchive,
                ),
            ],
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: children
                  .map((c) => CategoryChip(
                        category: c,
                        isSelected: false,
                        onTap: () {},
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
