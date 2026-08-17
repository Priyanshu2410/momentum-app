import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

/// One rounded pill. Used by the label filter row, the detail sheet's status
/// selector and the quick-add chips — same shape, different accent.
class FilterPill extends StatelessWidget {
  const FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
    this.accent = AppColors.accent,
    this.dotColor,
    this.height = 29,
    this.inactiveBackground = Colors.transparent,
    super.key,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color accent;

  /// Renders a 6px leading dot (status selector).
  final Color? dotColor;
  final double height;
  final Color inactiveBackground;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: dotColor == null ? 12 : 11),
        decoration: BoxDecoration(
          color: active ? accent.withValues(alpha: 0.12) : inactiveBackground,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: active ? accent.withValues(alpha: 0.45) : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: (dotColor == null ? AppTypography.pill : AppTypography.chip)
                  .copyWith(
                color: active ? accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
