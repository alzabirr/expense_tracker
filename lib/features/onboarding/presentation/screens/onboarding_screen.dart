import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/router/route_names.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/widgets/app_button.dart';
import 'package:spendra/features/settings/domain/entities/app_settings.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  String _selectedCurrency = 'USD';
  String _searchQuery = '';

  static const List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$', 'flag': '🇺🇸', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'flag': '🇪🇺', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'flag': '🇬🇧', 'name': 'British Pound'},
    {'code': 'CAD', 'symbol': 'C\$', 'flag': '🇨🇦', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'flag': '🇦🇺', 'name': 'Australian Dollar'},
    {'code': 'INR', 'symbol': '₹', 'flag': '🇮🇳', 'name': 'Indian Rupee'},
    {'code': 'PKR', 'symbol': 'Rs', 'flag': '🇵🇰', 'name': 'Pakistani Rupee'},
    {'code': 'AED', 'symbol': 'د.إ', 'flag': '🇦🇪', 'name': 'UAE Dirham'},
    {'code': 'SAR', 'symbol': '﷼', 'flag': '🇸🇦', 'name': 'Saudi Riyal'},
    {'code': 'QAR', 'symbol': 'QR', 'flag': '🇶🇦', 'name': 'Qatari Riyal'},
    {'code': 'KWD', 'symbol': 'KD', 'flag': '🇰🇼', 'name': 'Kuwaiti Dinar'},
    {'code': 'OMR', 'symbol': 'OMR', 'flag': '🇴🇲', 'name': 'Omani Rial'},
    {'code': 'BHD', 'symbol': 'BD', 'flag': '🇧🇭', 'name': 'Bahraini Dinar'},
    {'code': 'MYR', 'symbol': 'RM', 'flag': '🇲🇾', 'name': 'Malaysian Ringgit'},
    {'code': 'SGD', 'symbol': 'S\$', 'flag': '🇸🇬', 'name': 'Singapore Dollar'},
    {'code': 'JPY', 'symbol': '¥', 'flag': '🇯🇵', 'name': 'Japanese Yen'},
    {'code': 'CNY', 'symbol': '¥', 'flag': '🇨🇳', 'name': 'Chinese Yuan'},
    {'code': 'CHF', 'symbol': 'CHF', 'flag': '🇨🇭', 'name': 'Swiss Franc'},
    {'code': 'HKD', 'symbol': 'HK\$', 'flag': '🇭🇰', 'name': 'Hong Kong Dollar'},
    {'code': 'KRW', 'symbol': '₩', 'flag': '🇰🇷', 'name': 'South Korean Won'},
    {'code': 'NZD', 'symbol': 'NZ\$', 'flag': '🇳🇿', 'name': 'New Zealand Dollar'},
    {'code': 'IDR', 'symbol': 'Rp', 'flag': '🇮🇩', 'name': 'Indonesian Rupiah'},
    {'code': 'THB', 'symbol': '฿', 'flag': '🇹🇭', 'name': 'Thai Baht'},
    {'code': 'PHP', 'symbol': '₱', 'flag': '🇵🇭', 'name': 'Philippine Peso'},
    {'code': 'VND', 'symbol': '₫', 'flag': '🇻🇳', 'name': 'Vietnamese Dong'},
    {'code': 'BRL', 'symbol': 'R\$', 'flag': '🇧🇷', 'name': 'Brazilian Real'},
    {'code': 'MXN', 'symbol': 'Mex\$', 'flag': '🇲🇽', 'name': 'Mexican Peso'},
    {'code': 'ZAR', 'symbol': 'R', 'flag': '🇿🇦', 'name': 'South African Rand'},
    {'code': 'EGP', 'symbol': 'E£', 'flag': '🇪🇬', 'name': 'Egyptian Pound'},
    {'code': 'NGN', 'symbol': '₦', 'flag': '🇳🇬', 'name': 'Nigerian Naira'},
    {'code': 'TRY', 'symbol': '₺', 'flag': '🇹🇷', 'name': 'Turkish Lira'},
    {'code': 'RUB', 'symbol': '₽', 'flag': '🇷🇺', 'name': 'Russian Ruble'},
    {'code': 'SEK', 'symbol': 'kr', 'flag': '🇸🇪', 'name': 'Swedish Krona'},
    {'code': 'NOK', 'symbol': 'kr', 'flag': '🇳🇴', 'name': 'Norwegian Krone'},
    {'code': 'DKK', 'symbol': 'kr', 'flag': '🇩🇰', 'name': 'Danish Krone'},
    {'code': 'PLN', 'symbol': 'zł', 'flag': '🇵🇱', 'name': 'Polish Zloty'},
    {'code': 'BDT', 'symbol': '৳', 'flag': '🇧🇩', 'name': 'Bangladeshi Taka'},
  ];

  @override
  void initState() {
    super.initState();
    final currentCurrency = ref.read(currencyCodeProvider);
    _selectedCurrency = currentCurrency;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();

    final settingsRepo = ref.read(settingsRepositoryProvider);
    final currentSettings =
        ref.read(settingsStreamProvider).valueOrNull ?? AppSettings.defaults;

    await settingsRepo.save(
      currentSettings.copyWith(
        currencyCode: _selectedCurrency,
        isFirstLaunch: false,
      ),
    );

    if (!mounted) return;
    context.go(RouteNames.dashboard);
  }

  void _nextPage() {
    if (_currentPage < 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.base),

            // ── PageView Slides ──────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  // Slide 1: Expense Tracking
                  _buildSlide1(context, isDark),

                  // Slide 2: User Friendly Currency Setup
                  _buildCurrencySetupSlide(context, isDark),
                ],
              ),
            ),

            // ── Bottom Section: Page Indicators & Action Button ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.sm,
                AppSpacing.base,
                AppSpacing.base,
              ),
              child: Column(
                children: [
                  // Page Indicators (2 Slides)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 28 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.coral
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.12)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Primary Action Button
                  AppButton(
                    label: _currentPage == 1 ? 'Get Started' : 'Next',
                    onPressed: _nextPage,
                    icon: _currentPage == 1
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Slide 1: Welcome & Expense Tracking ──────────────────────────────────
  Widget _buildSlide1(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: 360,
                child: Image.asset(
                  'assets/images/track_expenses.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Text(
            'Track Expenses Effortlessly',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Log daily transactions in seconds, organize categories, and keep your finances crystal clear.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.4,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }

  // ── Slide 2: User Friendly Currency Setup ────────────────────────────────
  Widget _buildCurrencySetupSlide(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    final filteredCurrencies = _currencies.where((c) {
      final q = _searchQuery.toLowerCase().trim();
      if (q.isEmpty) return true;
      final name = c['name']?.toLowerCase() ?? '';
      final code = c['code']?.toLowerCase() ?? '';
      return name.contains(q) || code.contains(q);
    }).toList();

    final selectedItem = _currencies.firstWhere(
      (c) => c['code'] == _selectedCurrency,
      orElse: () => _currencies.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Select Currency',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Active Selected Currency Banner Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E2126)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.teal.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : AppColors.teal.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      selectedItem['flag']!,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedItem['name']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${selectedItem['code']} • Preview: ${selectedItem['symbol']} 2,500.00',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Premium Search Field ──────────────────────────────────
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF22262C)
                  : const Color(0xFFF1F4F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
              cursorColor: AppColors.teal,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search currency (e.g. BDT, Taka, USD, EUR)...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.cancel_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Scrollable Currency List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF181A1D)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: filteredCurrencies.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                  itemBuilder: (context, index) {
                    final c = filteredCurrencies[index];
                    final isSelected = _selectedCurrency == c['code'];

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 1,
                      ),
                      leading: Text(
                        c['flag']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      title: Text(
                        c['name']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.teal : null,
                        ),
                      ),
                      subtitle: Text(
                        '${c['code']} • ${c['symbol']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.teal,
                              size: 20,
                            )
                          : Text(
                              c['symbol']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCurrency = c['code']!);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
