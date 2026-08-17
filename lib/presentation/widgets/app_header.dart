import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/date_utils.dart';
import '../providers/board_filter_provider.dart';
import '../providers/tasks_provider.dart';
import 'progress_ring.dart';

/// Date eyebrow, headline, today's completion ring and the settings gear.
/// Shown on every tab — it sits above the tab body in the design too.
class AppHeader extends ConsumerWidget {
  const AppHeader({required this.onSettings, super.key});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Headline echoes the active stat card, falling back to "Today".
    final statusFilter = ref.watch(statusFilterProvider);
    final progress = ref.watch(todayProgressProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppDates.eyebrow(DateTime.now()).toUpperCase(),
                  style: AppTypography.eyebrow,
                ),
                const SizedBox(height: 9),
                Text(
                  statusFilter?.label ?? 'Today',
                  style: AppTypography.headline,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ProgressRing(progress: progress),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: onSettings,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Icon(
                AppIcons.settings,
                size: 21,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
