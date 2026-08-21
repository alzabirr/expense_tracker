import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/router/route_names.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/utils/currency_formatter.dart';
import 'package:spendra/core/widgets/app_button.dart';
import 'package:spendra/core/database/database_seeder.dart';
import 'package:spendra/core/database/isar_provider.dart';
import 'package:spendra/core/utils/csv_exporter.dart';
import 'package:spendra/features/settings/domain/entities/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsStreamProvider).valueOrNull;
    final currency = ref.watch(currencyCodeProvider);
    final symbol = CurrencyFormatter.symbol(currency);
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.base, AppSpacing.base, 0),
                child: Text('Settings', style: theme.textTheme.headlineMedium),
              ),
            ),


            // ── Appearance ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.xl, AppSpacing.base, AppSpacing.sm),
                child: Text('Appearance',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: textSecondary, letterSpacing: 0.8)),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: AppRadii.lgRadius,
                  ),
                  child: Column(
                    children: AppThemeMode.values.map((mode) {
                      final isSelected =
                          settings?.themeMode == mode || (settings == null && mode == AppThemeMode.system);
                      final label = switch (mode) {
                        AppThemeMode.system => 'System Default',
                        AppThemeMode.light => 'Light',
                        AppThemeMode.dark => 'Dark',
                      };
                      final icon = switch (mode) {
                        AppThemeMode.system => Icons.phone_android,
                        AppThemeMode.light => Icons.light_mode,
                        AppThemeMode.dark => Icons.dark_mode,
                      };
                      return _SettingsTile(
                        icon: icon,
                        title: label,
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.coral, size: 20)
                            : null,
                        onTap: () async {
                          await ref
                              .read(settingsRepositoryProvider)
                              .updateTheme(mode);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // ── Currency & Region ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.xl, AppSpacing.base, AppSpacing.sm),
                child: Text('Currency & Region',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: textSecondary, letterSpacing: 0.8)),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: AppRadii.lgRadius,
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.public_rounded,
                        title: 'Default Currency',
                        subtitle: _getCurrencySubtitle(settings?.currencyCode ?? 'USD'),
                        onTap: () => _showCurrencyPicker(context, ref, settings?.currencyCode ?? 'USD'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Data ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.xl, AppSpacing.base, AppSpacing.sm),
                child: Text('Data',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: textSecondary, letterSpacing: 0.8)),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: AppRadii.lgRadius,
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.category_outlined,
                        title: 'Manage Categories',
                        onTap: () => context.push(RouteNames.categoryManagement),
                      ),
                      _SettingsTile(
                        icon: Icons.savings_outlined,
                        title: 'Monthly Budget',
                        onTap: () => context.push(RouteNames.budgetScreen),
                      ),
                      _SettingsTile(
                        icon: Icons.download_outlined,
                        title: 'Export Data',
                        onTap: () async {
                          final expenses = ref.read(allExpensesStreamProvider).valueOrNull ?? [];
                          final categories = ref.read(categoriesStreamProvider).valueOrNull ?? [];
                          if (expenses.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No transactions available to export.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          await CsvExporter.exportAndShare(
                            expenses: expenses,
                            categories: categories,
                            currencySymbol: symbol,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── About ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.xl, AppSpacing.base, AppSpacing.sm),
                child: Text('About',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: textSecondary, letterSpacing: 0.8)),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: AppRadii.lgRadius,
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.auto_awesome_outlined,
                        title: 'App Tour / Onboarding',
                        subtitle: 'Revisit intro & walkthrough',
                        onTap: () => context.push(RouteNames.onboarding),
                      ),
                      _SettingsTile(
                        icon: Icons.info_outline,
                        title: 'Version',
                        subtitle: '1.0.0 (1)',
                        onTap: null,
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Danger zone ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AppButton(
                  label: 'Reset All Data',
                  variant: AppButtonVariant.danger,
                  onPressed: () => _confirmReset(context, ref),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  static const List<(String, String, String, String)> _allCurrencies = [
    ('USD', 'US Dollar', '\$', '🇺🇸'),
    ('EUR', 'Euro', '€', '🇪🇺'),
    ('GBP', 'British Pound', '£', '🇬🇧'),
    ('CAD', 'Canadian Dollar', 'C\$', '🇨🇦'),
    ('AUD', 'Australian Dollar', 'A\$', '🇦🇺'),
    ('INR', 'Indian Rupee', '₹', '🇮🇳'),
    ('PKR', 'Pakistani Rupee', 'Rs', '🇵🇰'),
    ('AED', 'UAE Dirham', 'د.إ', '🇦🇪'),
    ('SAR', 'Saudi Riyal', '﷼', '🇸🇦'),
    ('QAR', 'Qatari Riyal', 'QR', '🇶🇦'),
    ('KWD', 'Kuwaiti Dinar', 'KD', '🇰🇼'),
    ('OMR', 'Omani Rial', 'OMR', '🇴🇲'),
    ('BHD', 'Bahraini Dinar', 'BD', '🇧🇭'),
    ('MYR', 'Malaysian Ringgit', 'RM', '🇲🇾'),
    ('SGD', 'Singapore Dollar', 'S\$', '🇸🇬'),
    ('JPY', 'Japanese Yen', '¥', '🇯🇵'),
    ('CNY', 'Chinese Yuan', '¥', '🇨🇳'),
    ('CHF', 'Swiss Franc', 'CHF', '🇨🇭'),
    ('HKD', 'Hong Kong Dollar', 'HK\$', '🇭🇰'),
    ('KRW', 'South Korean Won', '₩', '🇰🇷'),
    ('NZD', 'New Zealand Dollar', 'NZ\$', '🇳🇿'),
    ('IDR', 'Indonesian Rupiah', 'Rp', '🇮🇩'),
    ('THB', 'Thai Baht', '฿', '🇹🇭'),
    ('PHP', 'Philippine Peso', '₱', '🇵🇭'),
    ('VND', 'Vietnamese Dong', '₫', '🇻🇳'),
    ('BRL', 'Brazilian Real', 'R\$', '🇧🇷'),
    ('MXN', 'Mexican Peso', 'Mex\$', '🇲🇽'),
    ('ZAR', 'South African Rand', 'R', '🇿🇦'),
    ('EGP', 'Egyptian Pound', 'E£', '🇪🇬'),
    ('NGN', 'Nigerian Naira', '₦', '🇳🇬'),
    ('TRY', 'Turkish Lira', '₺', '🇹🇷'),
    ('RUB', 'Russian Ruble', '₽', '🇷🇺'),
    ('SEK', 'Swedish Krona', 'kr', '🇸🇪'),
    ('NOK', 'Norwegian Krone', 'kr', '🇳🇴'),
    ('DKK', 'Danish Krone', 'kr', '🇩🇰'),
    ('PLN', 'Polish Zloty', 'zł', '🇵🇱'),
    ('BDT', 'Bangladeshi Taka', '৳', '🇧🇩'),
  ];

  String _getCurrencySubtitle(String code) {
    final match = _allCurrencies.firstWhere(
      (c) => c.$1 == code,
      orElse: () => ('USD', 'US Dollar', '\$', '💵'),
    );
    return '${match.$4} ${match.$2} (${match.$3})';
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref, String currentCode) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.45,
        expand: false,
        builder: (_, scrollController) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Currency & Region',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select your default regional currency',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: _allCurrencies.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    ),
                    itemBuilder: (context, index) {
                      final c = _allCurrencies[index];
                      final isSelected = c.$1 == currentCode;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.teal.withValues(alpha: 0.15)
                                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(c.$4, style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                        title: Text(
                          c.$2,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.teal : null,
                          ),
                        ),
                        subtitle: Text('${c.$1} • ${c.$3}'),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 22)
                            : Text(
                                c.$3,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                        onTap: () async {
                          await ref.read(settingsRepositoryProvider).updateCurrency(c.$1, 'en_US');
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
            'This will permanently delete all your transactions, budgets, and custom categories. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final isar = ref.read(isarProvider);
      await DatabaseSeeder.resetAllData(isar);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data reset successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: Icon(icon, color: AppColors.coral, size: 22),
        title: Text(title, style: theme.textTheme.bodyLarge),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(color: textSecondary))
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right,
                    color: textSecondary, size: 20)
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lgRadius),
      ),
    );
  }
}
