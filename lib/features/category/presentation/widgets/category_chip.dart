import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spendra/core/constants/app_icons.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_radii.dart';
import 'package:spendra/features/category/domain/entities/category.dart';

/// Pill-shaped category chip: icon + label, with selection animation.
class CategoryChip extends StatefulWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _scaleController.forward().then((_) => _scaleController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = AppColors.fromToken(widget.category.colorToken);
    final icon = AppIcons.get(widget.category.iconKey);

    final bg = widget.isSelected
        ? color.withValues(alpha: 0.18)
        : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated);

    final borderColor =
        widget.isSelected ? color : Colors.transparent;

    final textColor =
        widget.isSelected ? color : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6.5,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: widget.isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                widget.category.name,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontSize: 12.5,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon-only category avatar used in transaction tiles.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.category,
    this.size = 44,
  });

  final Category category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromToken(category.colorToken);
    final icon = AppIcons.get(category.iconKey);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadii.mdRadius,
      ),
      child: Icon(icon, color: color, size: size * 0.45),
    );
  }
}
