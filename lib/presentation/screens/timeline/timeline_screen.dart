import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/task.dart';
import '../../providers/board_filter_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../widgets/empty_state.dart';
import '../home/widgets/task_card.dart';
import '../task_detail/task_detail_sheet.dart';

sealed class _Row {
  const _Row();
}

class _SectionRow extends _Row {
  const _SectionRow(this.section, this.first);

  final TimelineSection section;
  final bool first;
}

class _DateRow extends _Row {
  const _DateRow(this.date, this.band);

  final DateTime date;
  final TimelineBand band;
}

class _TaskRow extends _Row {
  const _TaskRow(this.task, this.band, this.index, this.last);

  final Task task;
  final TimelineBand band;
  final int index;
  final bool last;
}

/// Past / Today / Upcoming for the selected month, grouped by day.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(timelineSectionsProvider);
    final now = DateTime.now();

    final rows = <_Row>[];
    var cardIndex = 0;
    for (final section in sections) {
      rows.add(_SectionRow(section, rows.isEmpty));
      for (final group in section.groups) {
        rows.add(_DateRow(group.date, section.band));
        for (var i = 0; i < group.tasks.length; i++) {
          rows.add(_TaskRow(
            group.tasks[i],
            section.band,
            cardIndex++,
            i == group.tasks.length - 1,
          ));
        }
      }
    }

    return Column(
      children: [
        const _MonthStepper(),
        Expanded(
          child: rows.isEmpty
              ? const SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: EmptyState(
                    title: AppStrings.nothingHere,
                    subtitle: 'Nothing scheduled this month.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.listBottomInset),
                  itemCount: rows.length,
                  itemBuilder: (context, i) => switch (rows[i]) {
                    _SectionRow(:final section, :final first) => Padding(
                        padding: EdgeInsets.only(top: first ? 0 : 10, bottom: 16),
                        child: _SectionHeading(section: section),
                      ),
                    _DateRow(:final date, :final band) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          AppDates.groupHeading(date, now),
                          style: AppTypography.meta.copyWith(
                            color: band == TimelineBand.past
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    _TaskRow(:final task, :final band, :final index, :final last) =>
                      Padding(
                        padding: EdgeInsets.only(bottom: last ? 18 : 10),
                        child: CompactTaskCard(
                          task: task,
                          index: index,
                          faded: band == TimelineBand.past,
                          highlightToday: band == TimelineBand.today,
                          onOpen: () => showTaskDetailSheet(context, ref, task.id),
                        ),
                      ),
                  },
                ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.section});

  final TimelineSection section;

  @override
  Widget build(BuildContext context) {
    final isToday = section.band == TimelineBand.today;
    final color = switch (section.band) {
      TimelineBand.past => AppColors.textMuted,
      TimelineBand.today => AppColors.accent,
      TimelineBand.upcoming => AppColors.textSecondary,
    };

    return Row(
      children: [
        if (isToday) ...[
          RepaintBoundary(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .boxShadow(
                  begin: const BoxShadow(color: Color(0x733FD6B4), spreadRadius: 0),
                  end: const BoxShadow(color: Color(0x003FD6B4), spreadRadius: 5),
                  duration: 1200.ms,
                ),
          ),
          const SizedBox(width: 10),
        ],
        Text(section.title.toUpperCase(),
            style: AppTypography.sectionHeader.copyWith(color: color)),
        const SizedBox(width: 10),
        Expanded(
          child: ColoredBox(
            color: isToday ? const Color(0x4D3FD6B4) : AppColors.hairline,
            child: const SizedBox(height: 1),
          ),
        ),
      ],
    );
  }
}

class _MonthStepper extends ConsumerWidget {
  const _MonthStepper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(timelineMonthProvider);
    final offset = ref.watch(timelineMonthOffsetProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 22, AppSpacing.xl, 22),
      child: Row(
        children: [
          _Chevron(
            icon: AppIcons.chevronLeft,
            onTap: () =>
                ref.read(timelineMonthOffsetProvider.notifier).state = offset - 1,
          ),
          const SizedBox(width: 14),
          Text(
            AppDates.month(month),
            style: AppTypography.fieldLabel.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 14),
          _Chevron(
            icon: AppIcons.chevronRight,
            onTap: () =>
                ref.read(timelineMonthOffsetProvider.notifier).state = offset + 1,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                ref.read(timelineMonthOffsetProvider.notifier).state = 0,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accentTint,
                borderRadius: AppRadius.pill,
                border: Border.all(color: AppColors.accentEdge),
              ),
              child: Text('Today',
                  style: AppTypography.pill.copyWith(color: AppColors.accent)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, size: 22, color: AppColors.textSecondary),
    );
  }
}
