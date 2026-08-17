import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/task.dart';
import '../../../../domain/enums/task_status.dart';
import '../../../actions/task_actions.dart';
import '../../../providers/tasks_provider.dart';
import '../../../providers/ui_feedback_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';
import '../../task_detail/task_detail_sheet.dart';
import 'task_card.dart';

sealed class _Row {
  const _Row();
}

class _GroupHeader extends _Row {
  const _GroupHeader(this.status, this.count, this.first);

  final TaskStatus status;
  final int count;
  final bool first;
}

class _TaskRow extends _Row {
  const _TaskRow(this.task, this.index);

  final Task task;
  final int index;
}

/// Vertical scan-first home: status groups stacked, empty ones omitted.
class TaskListView extends ConsumerWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedTasksProvider);
    final pulsing = ref.watch(pulseProvider);

    // Flattened so the whole screen is one ListView.builder rather than a
    // Column of nested lists.
    final rows = <_Row>[];
    var cardIndex = 0;
    for (final status in TaskStatus.values) {
      final tasks = grouped[status]!;
      if (tasks.isEmpty) continue;
      rows.add(_GroupHeader(status, tasks.length, rows.isEmpty));
      for (final task in tasks) {
        rows.add(_TaskRow(task, cardIndex++));
      }
    }

    if (rows.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.listBottomInset),
        child: EmptyState(
          title: AppStrings.nothingHere,
          subtitle: AppStrings.nothingHereHint,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, 6, AppSpacing.xl, AppSpacing.listBottomInset),
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final row = rows[i];
        return switch (row) {
          _GroupHeader(:final status, :final count, :final first) => Padding(
              padding: EdgeInsets.only(top: first ? 0 : 26, bottom: 13),
              child: SectionHeader(
                title: status.label,
                color: status.color,
                count: count,
                breathing: status == TaskStatus.inProgress,
              ),
            ),
          _TaskRow(:final task, :final index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TaskCard(
                task: task,
                index: index,
                pulsing: pulsing.contains(task.id),
                onOpen: () => showTaskDetailSheet(context, ref, task.id),
                onComplete: () => ref.completeTask(task),
                onDelete: () => ref.deleteTask(task),
                onSnooze: () async {
                  final when = await showSnoozeSheet(context, task);
                  if (when != null) await ref.snoozeTaskTo(task, when);
                },
              ),
            ),
        };
      },
    );
  }
}
