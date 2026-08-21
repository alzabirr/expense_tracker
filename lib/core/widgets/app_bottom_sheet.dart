import 'package:flutter/material.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/theme/app_shadows.dart';

/// Shared bottom sheet shell. Wraps content with a drag handle and
/// consistent surface styling.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? trailing,
    bool isScrollControlled = true,
    bool useRootNavigator = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => AppBottomSheet(
        title: title,
        trailing: trailing,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadii.sheetRadius,
        boxShadow: AppShadows.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkDivider
                    : AppColors.lightDivider,
                borderRadius: AppRadii.pillRadius,
              ),
            ),
          ),
          // Title row
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.base,
                AppSpacing.xl,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title!,
                    style: theme.textTheme.headlineSmall,
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ],
          // Content
          Flexible(
            child: Padding(
              padding: padding ??
                  const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.base,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
