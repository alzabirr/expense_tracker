import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/router/route_names.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/database/isar_provider.dart';
import 'package:spendra/core/utils/currency_formatter.dart';
import 'package:spendra/core/utils/csv_exporter.dart';
import 'package:spendra/core/utils/data_importer.dart';
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
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

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

            // ── Account & Profile ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.lg, AppSpacing.base, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: AppRadii.lgRadius,
                    border: Border.all(
                      color: user != null
                          ? AppColors.teal.withValues(alpha: 0.3)
                          : AppColors.coral.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => context.push(RouteNames.userProfile),
                        borderRadius: user != null
                            ? const BorderRadius.vertical(top: Radius.circular(24))
                            : AppRadii.lgRadius,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: user != null
                              ? Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor:
                                          AppColors.teal.withValues(alpha: 0.2),
                                      child: Text(
                                        (user.name?.isNotEmpty == true
                                                ? user.name![0]
                                                : user.email.isNotEmpty
                                                    ? user.email[0]
                                                    : 'U')
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  user.name ?? 'Spendra User',
                                                  style: theme
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.teal
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  'PRO',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.teal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            user.email,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(color: textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.teal,
                                      size: 24,
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.coral
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.cloud_sync_outlined,
                                        color: AppColors.coral,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Guest Account',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Sign in to sync your data with Supabase',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(color: textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.coral,
                                      size: 24,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (user != null) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Supabase Cloud Sync Active',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: authState.isSyncing
                                    ? null
                                    : () async {
                                        await ref
                                            .read(
                                                authControllerProvider.notifier)
                                            .syncData();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Cloud sync completed!'),
                                              backgroundColor: AppColors.teal,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                icon: authState.isSyncing
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.teal,
                                        ),
                                      )
                                    : const Icon(Icons.sync, size: 16),
                                label: Text(
                                  authState.isSyncing ? 'Syncing...' : 'Sync Now',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── Account Section ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.xl, AppSpacing.base, AppSpacing.sm),
                child: Text('Account',
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
                        icon: Icons.person_outline_rounded,
                        title: 'Profile',
                        subtitle: user != null
                            ? (user.name ?? user.email)
                            : 'View account & profile details',
                        onTap: () => context.push(RouteNames.userProfile),
                      ),
                      if (user == null)
                        _SettingsTile(
                          icon: Icons.login_rounded,
                          title: 'Sign In / Register',
                          subtitle: 'Sync your data to cloud',
                          onTap: () => context.push(RouteNames.login),
                        ),
                    ],
                  ),
                ),
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
                        icon: Icons.upload_outlined,
                        title: 'Import Data',
                        onTap: () => _showImportSheet(context, ref),
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

  void _showImportSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImportDataSheet(ref: ref),
    );
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

class _ImportDataSheet extends StatefulWidget {
  const _ImportDataSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_ImportDataSheet> createState() => _ImportDataSheetState();
}

class _ImportDataSheetState extends State<_ImportDataSheet> {
  final _textController = TextEditingController();
  bool _isLoading = false;
  bool _showPasteBox = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleFileImport() async {
    setState(() => _isLoading = true);
    final isar = widget.ref.read(isarProvider);
    final categories = widget.ref.read(categoriesStreamProvider).valueOrNull ?? [];

    final result = await DataImporter.pickAndImport(
      isar: isar,
      categories: categories,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.cancelled) return;

    Navigator.of(context).pop();
    _showResultSnackbar(result);
  }

  Future<void> _handleTextImport() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please paste some CSV data first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final isar = widget.ref.read(isarProvider);
    final categories = widget.ref.read(categoriesStreamProvider).valueOrNull ?? [];

    final result = await DataImporter.importFromCsvString(
      csvString: text,
      isar: isar,
      categories: categories,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pop();
    _showResultSnackbar(result);
  }

  void _showResultSnackbar(ImportResult result) {
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Successfully imported ${result.importedCount} transaction${result.importedCount == 1 ? '' : 's'}!',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.errorMessage ?? 'Failed to import data.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
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

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
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
              Text(
                'Import Transactions',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Import expenses and income from any CSV file or text',
                style: theme.textTheme.bodySmall?.copyWith(color: textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_isLoading) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: AppColors.coral),
                  ),
                ),
              ] else ...[
                // Option 1: File Picker Card
                InkWell(
                  onTap: _handleFileImport,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.coral.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.coral.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.upload_file_outlined,
                            color: AppColors.coral,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select CSV File',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Choose .csv or .txt file from device',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.coral,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Option 2: Paste CSV Text Toggle
                InkWell(
                  onTap: () => setState(() => _showPasteBox = !_showPasteBox),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.paste_outlined,
                            color: isDark ? Colors.white70 : Colors.black87,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paste CSV Text',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Directly paste table or spreadsheet rows',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _showPasteBox
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                if (_showPasteBox) ...[
                  const SizedBox(height: AppSpacing.base),
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText:
                          'Date,Title,Type,Category,Amount\n2026-08-20,Coffee,expense,Food,4.50',
                      hintStyle: TextStyle(
                        color: textSecondary.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(
                              text: DataImporter.sampleCsvTemplate,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sample CSV copied to clipboard!'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_outlined, size: 16),
                        label: const Text(
                          'Copy Sample CSV',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _handleTextImport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.coral,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Import Now',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
