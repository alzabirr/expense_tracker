import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/category/presentation/widgets/category_chip.dart';
import 'package:spendra/features/expense/presentation/screens/add_edit_expense_screen.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends ConsumerState<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    int catTime(Category c) {
      if (c.sortOrder > 0) return c.sortOrder;
      final numMatch = RegExp(r'(\d+)').firstMatch(c.id);
      if (numMatch != null) return int.tryParse(numMatch.group(1)!) ?? 0;
      return 0;
    }

    final customCategories = (ref.watch(categoriesStreamProvider).valueOrNull ?? [])
        .where((c) => !c.isDefault)
        .toList()
      ..sort((a, b) {
        final tA = catTime(a);
        final tB = catTime(b);
        if (tA != tB) return tB.compareTo(tA);
        return b.id.compareTo(a.id);
      });

    final customExpense = customCategories
        .where((c) => c.parentId != 'cat_income' && !c.id.contains('_inc_'))
        .toList();
    final customIncome = customCategories
        .where((c) => c.parentId == 'cat_income' || c.id.contains('_inc_'))
        .toList();

    final allExpenseCategories = [...customExpense, ...defaultExpenseCategories];
    final allIncomeCategories = [...customIncome, ...defaultIncomeCategories];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.coral,
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [
            Tab(text: 'Expense Categories'),
            Tab(text: 'Income Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryListView(
            categories: allExpenseCategories,
            surface: surface,
            textSecondary: textSecondary,
            onDelete: (id) => ref.read(categoryRepositoryProvider).delete(id),
          ),
          _CategoryListView(
            categories: allIncomeCategories,
            surface: surface,
            textSecondary: textSecondary,
            onDelete: (id) => ref.read(categoryRepositoryProvider).delete(id),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref, isDark),
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Category', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref, bool isDark) {
    final nameCtrl = TextEditingController();
    String selectedColor = 'coral';
    String? selectedIcon;
    bool isExpenseType = _tabController.index == 0;

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
          final activeThemeColor = isExpenseType ? AppColors.coral : AppColors.teal;
          final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

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
                        'New Custom Category',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Type Selector (Expense or Income)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() {
                              isExpenseType = true;
                              selectedColor = 'coral';
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isExpenseType ? AppColors.coral : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Expense Category',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isExpenseType ? Colors.white : textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() {
                              isExpenseType = false;
                              selectedColor = 'teal';
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isExpenseType ? AppColors.teal : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Income Category',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !isExpenseType ? Colors.white : textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Category Name (e.g. Snacks, Gym, Tuition)',
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'SELECT ICON',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 140,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: iconChoices.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (context, idx) {
                        final item = iconChoices[idx];
                        final isSelected = item.$1 == selectedIcon;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedIcon = item.$1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activeThemeColor.withValues(alpha: 0.2)
                                  : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? activeThemeColor : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              item.$2,
                              size: 20,
                              color: isSelected
                                  ? activeThemeColor
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
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
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
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

                        final newCat = Category(
                          id: 'cat_custom_${isExpenseType ? "exp" : "inc"}_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          iconKey: selectedIcon ?? (isExpenseType ? 'shopping_bag' : 'banknote'),
                          colorToken: selectedColor,
                          parentId: isExpenseType ? 'cat_expense' : 'cat_income',
                          isDefault: false,
                          sortOrder: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        );

                        await ref.read(categoryRepositoryProvider).add(newCat);
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
                      child: const Text('Create Category', style: TextStyle(fontWeight: FontWeight.bold)),
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

class _CategoryListView extends StatelessWidget {
  const _CategoryListView({
    required this.categories,
    required this.surface,
    required this.textSecondary,
    required this.onDelete,
  });

  final List<Category> categories;
  final Color surface;
  final Color textSecondary;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.md, AppSpacing.base, 100),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, i) {
        final cat = categories[i];
        final color = AppColors.fromToken(cat.colorToken);

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: AppRadii.mdRadius,
          ),
          child: Row(
            children: [
              CategoryAvatar(category: cat),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  cat.name,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (cat.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
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
              else
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: Colors.redAccent,
                  tooltip: 'Delete custom category',
                  onPressed: () => onDelete(cat.id),
                ),
            ],
          ),
        );
      },
    );
  }
}
