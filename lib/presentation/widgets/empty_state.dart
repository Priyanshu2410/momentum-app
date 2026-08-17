import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// The floating outlined circle used wherever a list runs dry.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.subtitle,
    this.compact = false,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// Board columns use a smaller, tighter variant.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 52.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 40 : 90),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderStrong),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -6, duration: 1500.ms, curve: Curves.easeInOut)
                .fade(begin: 0.5, end: 0.85, duration: 1500.ms),
          ),
          SizedBox(height: compact ? 12 : 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: compact
                ? AppTypography.meta
                : AppTypography.cardTitle.copyWith(fontSize: 15, height: 1),
          ),
          if (subtitle != null && !compact) ...[
            const SizedBox(height: 10),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTypography.meta.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

/// Concentric-rings illustration for the empty Notifications screen.
class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 120, 30, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            child: SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                children: [
                  _ring(inset: 0, border: AppColors.borderStrong, delay: 0.ms),
                  _ring(inset: 22, border: const Color(0x523FD6B4), delay: 600.ms),
                  _ring(inset: 42, fill: const Color(0x333FD6B4), delay: 1200.ms),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(title,
              style: AppTypography.cardTitle.copyWith(fontSize: 16, height: 1)),
          const SizedBox(height: 8),
          SizedBox(
            width: 230,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.meta.copyWith(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring({
    required double inset,
    required Duration delay,
    Color? border,
    Color? fill,
  }) {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: border == null ? null : Border.all(color: border),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true), delay: delay)
            .moveY(begin: 0, end: -6, duration: 1500.ms, curve: Curves.easeInOut)
            .fade(begin: 0.5, end: 0.85, duration: 1500.ms),
      ),
    );
  }
}
