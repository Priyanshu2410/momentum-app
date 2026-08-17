import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../domain/enums/task_status.dart';
import '../../../providers/board_filter_provider.dart';
import '../../../providers/tasks_provider.dart';

/// Three tappable counters. Tapping one filters the board to that status;
/// tapping the active one clears the filter.
class StatCards extends ConsumerWidget {
  const StatCards({super.key});

  /// Order and copy from the design.
  static const _cards = <(TaskStatus, String)>[
    (TaskStatus.inProgress, 'In progress'),
    (TaskStatus.scheduled, 'Scheduled'),
    (TaskStatus.overdue, 'Overdue'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(statusCountsProvider);
    final active = ref.watch(statusFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
      child: Row(
        children: [
          for (final (status, name) in _cards) ...[
            Expanded(
              child: _StatCard(
                status: status,
                name: name,
                count: counts[status] ?? 0,
                active: active == status,
                onTap: () => ref.read(statusFilterProvider.notifier).state =
                    active == status ? null : status,
              ),
            ),
            if (status != _cards.last.$1) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.status,
    required this.name,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final TaskStatus status;
  final String name;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
        decoration: BoxDecoration(
          color: active ? status.tint : AppColors.surface1,
          borderRadius: AppRadius.control,
          border: Border.all(color: active ? status.color : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$count',
                style: AppTypography.statValue.copyWith(color: status.color)),
            const SizedBox(height: 7),
            Text(name, style: AppTypography.statLabel),
          ],
        ),
      ),
    );
  }
}
