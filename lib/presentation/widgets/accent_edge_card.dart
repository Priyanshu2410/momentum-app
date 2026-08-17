import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A rounded card with a coloured 2px left edge.
///
/// The edge is a child widget rather than `Border(left: BorderSide(...))` on a
/// BoxDecoration. Flutter refuses to paint a border whose sides have different
/// colours together with a `borderRadius` — see the assert in
/// `box_border.dart`, "A borderRadius can only be given on borders with uniform
/// colors". It throws during paint, which drops the border *and every child of
/// the card*, leaving an empty rounded rectangle with no error surfaced in
/// release. Keeping the box border uniform and drawing the edge separately
/// sidesteps that entirely.
class AccentEdgeCard extends StatelessWidget {
  const AccentEdgeCard({
    required this.accent,
    required this.background,
    required this.padding,
    required this.child,
    this.borderRadius = AppRadius.card,
    this.boxShadow,
    super.key,
  });

  final Color accent;
  final Color background;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final BorderRadius borderRadius;
  final List<BoxShadow>? boxShadow;

  static const double edgeWidth = 2;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: borderRadius,
        // Uniform colour — legal alongside a radius.
        border: Border.all(color: AppColors.border),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            // Non-positioned, so the Stack takes its size from the content.
            Padding(padding: padding, child: child),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: edgeWidth,
              child: AnimatedContainer(
                // Status changes fade the edge across rather than snapping.
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
