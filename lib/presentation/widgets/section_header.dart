import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// "● IN PROGRESS  3 ─────────" — the list group and board column heading.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.color,
    this.count,
    this.breathing = false,
    this.countOnRight = false,
    this.showRule = true,
    super.key,
  });

  final String title;
  final Color color;
  final int? count;

  /// In Progress gets a slow breathing dot, as in the design.
  final bool breathing;

  /// Board columns push the count to the far right; list groups keep it inline.
  final bool countOnRight;
  final bool showRule;

  @override
  Widget build(BuildContext context) {
    Widget dot = Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    if (breathing) {
      dot = RepaintBoundary(
        child: dot
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 1300.ms)
            .then()
            .fade(begin: 1, end: 0.35, duration: 1300.ms),
      );
    }

    return Row(
      children: [
        dot,
        const SizedBox(width: 9),
        Text(title.toUpperCase(), style: AppTypography.sectionHeader),
        if (count != null && !countOnRight) ...[
          const SizedBox(width: 9),
          Text('$count',
              style: AppTypography.sectionHeader
                  .copyWith(color: AppColors.textMuted, letterSpacing: 0)),
        ],
        if (countOnRight) ...[
          const Spacer(),
          Text('$count',
              style: AppTypography.sectionHeader
                  .copyWith(color: AppColors.textMuted, letterSpacing: 0)),
        ],
        if (showRule && !countOnRight) ...[
          const SizedBox(width: 9),
          const Expanded(child: ColoredBox(color: AppColors.hairline, child: SizedBox(height: 1))),
        ],
      ],
    );
  }
}
