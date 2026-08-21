import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:spendra/core/router/route_names.dart';
import 'package:spendra/core/theme/app_colors.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  static const List<_NavItemData> _tabs = [
    _NavItemData(
      selectedIcon: CupertinoIcons.house_fill,
      unselectedIcon: CupertinoIcons.house,
      label: 'Home',
      route: RouteNames.dashboard,
    ),
    _NavItemData(
      selectedIcon: CupertinoIcons.creditcard_fill,
      unselectedIcon: CupertinoIcons.creditcard,
      label: 'Transactions',
      route: RouteNames.transactions,
    ),
    _NavItemData(
      selectedIcon: CupertinoIcons.chart_pie_fill,
      unselectedIcon: CupertinoIcons.chart_pie,
      label: 'Reports',
      route: RouteNames.reports,
    ),
    _NavItemData(
      selectedIcon: CupertinoIcons.gear_alt_fill,
      unselectedIcon: CupertinoIcons.gear_alt,
      label: 'Settings',
      route: RouteNames.profile,
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(RouteNames.transactions)) return 1;
    if (location.startsWith(RouteNames.reports)) return 2;
    if (location.startsWith(RouteNames.profile)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = _currentIndex(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final navBottom = bottomInset > 0 ? bottomInset : 14.0;
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Content
          Positioned.fill(child: child),

          // Floating 'Add Expense' Action Button on Home Screen
          if (currentIndex == 0 && !isKeyboardVisible)
            Positioned(
              right: 16,
              bottom: navBottom + 92,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(RouteNames.addExpense);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Add Expense',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Floating Glass Capsule Navigation Bar
          if (!isKeyboardVisible)
            Positioned(
              left: 16,
              right: 16,
              bottom: navBottom,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(38),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Container(
                    height: 66,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(38),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                const Color(0xFF2A2A2E).withValues(alpha: 0.35),
                                const Color(0xFF141416).withValues(alpha: 0.15),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.28),
                                Colors.white.withValues(alpha: 0.08),
                              ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.20)
                            : Colors.white.withValues(alpha: 0.65),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.04),
                          blurRadius: 24,
                          spreadRadius: -3,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: List.generate(_tabs.length, (index) {
                        final tab = _tabs[index];
                        final isSelected = index == currentIndex;

                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.go(tab.route);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.coral.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected
                                        ? tab.selectedIcon
                                        : tab.unselectedIcon,
                                    size: 22,
                                    color: isSelected
                                        ? AppColors.coral
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                  ),
                                  const SizedBox(height: 3),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.coral
                                          : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary),
                                      letterSpacing: -0.2,
                                    ),
                                    child: Text(
                                      tab.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String label;
  final String route;

  const _NavItemData({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
    required this.route,
  });
}
