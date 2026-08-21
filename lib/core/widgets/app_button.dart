import 'package:flutter/material.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/theme/app_shadows.dart';

enum AppButtonVariant { primary, secondary, danger }

/// Full-width or sized pill button matching the Momentum design system.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.hasShadow = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = onPressed == null;

    Color bgColor;
    Color fgColor;
    List<BoxShadow> shadows;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = isDisabled
            ? (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated)
            : AppColors.coral;
        fgColor = isDisabled ? AppColors.darkTextSecondary : Colors.white;
        shadows = (isDisabled || !hasShadow) ? [] : AppShadows.fab;
      case AppButtonVariant.secondary:
        bgColor = Colors.transparent;
        fgColor = AppColors.coral;
        shadows = [];
      case AppButtonVariant.danger:
        bgColor = AppColors.danger.withValues(alpha: 0.12);
        fgColor = AppColors.danger;
        shadows = [];
    }

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fgColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fgColor, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final button = GestureDetector(
      onTap: isDisabled || isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        width: isFullWidth ? double.infinity : null,
        padding: isFullWidth
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.base,
              ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadii.pillRadius,
          boxShadow: shadows,
          border: variant == AppButtonVariant.secondary
              ? Border.all(color: AppColors.coral, width: 1.5)
              : null,
        ),
        child: Center(child: child),
      ),
    );

    return button;
  }
}
