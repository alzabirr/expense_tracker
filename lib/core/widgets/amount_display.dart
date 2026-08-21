import 'package:flutter/material.dart';
import 'package:spendra/core/theme/app_colors.dart';
import 'package:spendra/core/theme/app_spacing.dart';
import 'package:spendra/core/utils/currency_formatter.dart';

/// Animated count-up display for monetary amounts.
/// Tweens from the previous value to [amount] over [duration].
class AmountDisplay extends StatefulWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    required this.symbol,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.color,
  });

  final double amount;
  final String symbol;
  final TextStyle? style;
  final Duration duration;
  final Color? color;

  @override
  State<AmountDisplay> createState() => _AmountDisplayState();
}

class _AmountDisplayState extends State<AmountDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousAmount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.amount,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AmountDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _previousAmount = _animation.value;
      _animation = Tween<double>(
        begin: _previousAmount,
        end: widget.amount,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle = widget.style ?? theme.textTheme.displayLarge;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final value = _animation.value;
        final isNegative = value < 0;
        final abs = value.abs();
        final formatted = CurrencyFormatter.formatAmount(abs);

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isNegative)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '-',
                  style: effectiveStyle?.copyWith(
                    color: widget.color ?? AppColors.coral,
                    fontSize: (effectiveStyle.fontSize ?? 40) * 0.7,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.symbol,
                style: effectiveStyle?.copyWith(
                  color: widget.color ??
                      (widget.amount < 0
                          ? AppColors.coral
                          : AppColors.teal),
                  fontSize: (effectiveStyle.fontSize ?? 40) * 0.55,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              formatted,
              style: effectiveStyle?.copyWith(
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Simple non-animated amount label for list items.
class AmountLabel extends StatelessWidget {
  const AmountLabel({
    super.key,
    required this.amount,
    required this.symbol,
    required this.isExpense,
    this.style,
  });

  final double amount;
  final String symbol;
  final bool isExpense;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isExpense ? AppColors.coral : AppColors.teal;
    final sign = isExpense ? '-' : '+';
    final effective = (style ?? theme.textTheme.titleMedium)?.copyWith(
      color: color,
      fontWeight: FontWeight.w700,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$sign$symbol${CurrencyFormatter.formatAmount(amount)}',
        style: effective,
      ),
    );
  }
}
