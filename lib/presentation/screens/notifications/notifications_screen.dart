import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/app_notification.dart';
import '../../providers/app_providers.dart';
import '../../providers/notifications_provider.dart';
import '../../widgets/accent_edge_card.dart';
import '../../widgets/empty_state.dart';
import '../task_detail/task_detail_sheet.dart';

sealed class _Row {
  const _Row();
}

class _HeadingRow extends _Row {
  const _HeadingRow(this.title, this.first);

  final String title;
  final bool first;
}

class _ItemRow extends _Row {
  const _ItemRow(this.item, this.index);

  final AppNotification item;
  final int index;
}

/// History of everything that fired, grouped Today / Yesterday / Earlier.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupedNotificationsProvider);
    final now = DateTime.now();

    final rows = <_Row>[];
    var index = 0;
    for (final group in groups) {
      rows.add(_HeadingRow(group.title, rows.isEmpty));
      for (final item in group.items) {
        rows.add(_ItemRow(item, index++));
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 24, AppSpacing.xl, 20),
          child: Row(
            children: [
              const Text('Notifications', style: AppTypography.screenTitle),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    ref.read(taskRepositoryProvider).clearNotifications(),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'Clear all',
                  style: AppTypography.fieldValue.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: rows.isEmpty
              ? const SingleChildScrollView(
                  child: NotificationsEmptyState(
                    title: AppStrings.allClear,
                    subtitle: AppStrings.allClearHint,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.listBottomInset),
                  itemCount: rows.length,
                  itemBuilder: (context, i) => switch (rows[i]) {
                    _HeadingRow(:final title, :final first) => Padding(
                        padding: EdgeInsets.only(top: first ? 0 : 26, bottom: 12),
                        child: Text(title.toUpperCase(),
                            style: AppTypography.sectionHeader),
                      ),
                    _ItemRow(:final item, :final index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _NotificationTile(
                          item: item,
                          index: index,
                          relative: AppDates.relative(item.createdAt, now),
                          onTap: () async {
                            await ref
                                .read(taskRepositoryProvider)
                                .markNotificationRead(item.id);
                            if (context.mounted) {
                              await showTaskDetailSheet(
                                  context, ref, item.taskId);
                            }
                          },
                        ),
                      ),
                  },
                ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.index,
    required this.relative,
    required this.onTap,
  });

  final AppNotification item;
  final int index;
  final String relative;
  final VoidCallback onTap;

  Color get _dotColor => switch (item.kind) {
        NotificationKind.started => AppColors.accent,
        NotificationKind.dueSoon => AppColors.priorityMedium,
        NotificationKind.overdue => AppColors.statusOverdue,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AccentEdgeCard(
        // Unread carries a teal edge; read rows leave it blank.
        accent: item.isRead ? Colors.transparent : AppColors.accent,
        background: AppColors.surface1,
        borderRadius: AppRadius.notification,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: _dotColor, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(item.message, style: AppTypography.notification),
            ),
            const SizedBox(width: 11),
            Text(relative, style: AppTypography.meta.copyWith(height: 1.4)),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 60).ms)
        .moveY(begin: 10, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
