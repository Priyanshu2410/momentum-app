import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';
import '../providers/app_providers.dart';
import '../providers/ui_feedback_provider.dart';

/// Card and sheet actions in one place, so every entry point produces the same
/// side effects — persist, reschedule notifications, then toast.
extension TaskActions on WidgetRef {
  Future<void> completeTask(Task task) async {
    await read(taskRepositoryProvider).completeTask(task);
    read(toastProvider.notifier).show(
      task.repeats ? 'Done — next one scheduled' : 'Done',
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> setTaskStatus(Task task, TaskStatus status) =>
      read(taskRepositoryProvider).setStatus(task, status);

  Future<void> deleteTask(Task task) async {
    await read(taskRepositoryProvider).deleteTask(task);
    read(toastProvider.notifier)
        .show(AppStrings.taskDeleted, duration: const Duration(seconds: 2));
  }

  Future<void> snoozeTaskTo(Task task, DateTime start) async {
    await read(taskRepositoryProvider).snoozeTask(task, start);
    read(toastProvider.notifier).show(
      'Snoozed to ${AppDates.day(start)} · ${AppDates.time(start)}',
      duration: const Duration(seconds: 2),
    );
  }
}

/// "Snooze for: 1 hour / 3 hours / Tomorrow morning / Pick time".
/// Returns the chosen start time, or null if dismissed.
Future<DateTime?> showSnoozeSheet(BuildContext context, Task task) async {
  final now = DateTime.now();
  final options = <String, DateTime>{
    '1 hour': now.add(const Duration(hours: 1)),
    '3 hours': now.add(const Duration(hours: 3)),
    'Tomorrow morning': AppDates.tomorrowMorning(now),
  };

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: AppColors.surface1,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
    useSafeArea: true,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Snooze for',
                style: AppTypography.fieldLabel
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            for (final entry in options.entries)
              _SnoozeRow(
                label: entry.key,
                detail:
                    '${AppDates.day(entry.value)} · ${AppDates.time(entry.value)}',
                onTap: () => Navigator.of(sheetContext).pop(entry.value),
              ),
            _SnoozeRow(
              label: 'Pick time',
              detail: '',
              onTap: () async {
                final picked = await pickDateTime(sheetContext, task.startDateTime);
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop(picked);
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Date then time, in two standard pickers. Returns null if either is skipped.
Future<DateTime?> pickDateTime(BuildContext context, DateTime initial) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime.now().subtract(const Duration(days: 1)),
    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
  );
  if (date == null || !context.mounted) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
  );
  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

class _SnoozeRow extends StatelessWidget {
  const _SnoozeRow({
    required this.label,
    required this.detail,
    required this.onTap,
  });

  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: AppRadius.control,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(label,
                style: AppTypography.fieldLabel
                    .copyWith(color: AppColors.textPrimary)),
            const Spacer(),
            Text(detail, style: AppTypography.meta),
          ],
        ),
      ),
    );
  }
}
