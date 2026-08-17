import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';
import 'app_providers.dart';
import 'board_filter_provider.dart';

/// The single Drift-backed stream everything else derives from.
final tasksProvider = StreamProvider<List<Task>>(
  (ref) => ref.watch(taskRepositoryProvider).watchTasks(),
);

/// Label filter only. Feeds the stat cards and the timeline, both of which
/// ignore the status filter.
final labelFilteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? const <Task>[];
  final label = ref.watch(labelFilterProvider);
  if (label == null) return tasks;
  return tasks.where((t) => t.label == label).toList();
});

/// Label + status filter. Feeds the list and board.
final visibleTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(labelFilteredTasksProvider);
  final status = ref.watch(statusFilterProvider);
  if (status == null) return tasks;
  return tasks.where((t) => t.status == status).toList();
});

/// Keyed in `TaskStatus.values` order, which is the design's column order.
/// Always contains all four keys — the board renders empty columns, the list
/// skips them.
final groupedTasksProvider = Provider<Map<TaskStatus, List<Task>>>((ref) {
  final tasks = ref.watch(visibleTasksProvider);
  return {
    for (final status in TaskStatus.values)
      status: tasks.where((t) => t.status == status).toList(),
  };
});

/// Counts behind the three stat cards. Deliberately not status-filtered, so
/// the cards keep working as a toggle once one is active.
final statusCountsProvider = Provider<Map<TaskStatus, int>>((ref) {
  final tasks = ref.watch(labelFilteredTasksProvider);
  return {
    for (final status in TaskStatus.values)
      status: tasks.where((t) => t.status == status).length,
  };
});

/// Fraction of today's tasks that are done — the header ring.
final todayProgressProvider = Provider<double>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? const <Task>[];
  final now = DateTime.now();
  final todays =
      tasks.where((t) => AppDates.isSameDay(t.startDateTime, now)).toList();
  if (todays.isEmpty) return 0;
  return todays.where((t) => t.isDone).length / todays.length;
});

/// Single task by id, for the detail sheet. Reads from the same stream so an
/// edit elsewhere is reflected immediately.
final taskByIdProvider = Provider.family<Task?, int>((ref, id) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? const <Task>[];
  for (final task in tasks) {
    if (task.id == id) return task;
  }
  return null;
});

// ------------------------------------------------------------------ timeline

class TimelineGroup {
  const TimelineGroup({required this.date, required this.tasks});

  final DateTime date;
  final List<Task> tasks;
}

enum TimelineBand { past, today, upcoming }

class TimelineSection {
  const TimelineSection({required this.band, required this.groups});

  final TimelineBand band;
  final List<TimelineGroup> groups;

  String get title => switch (band) {
        TimelineBand.past => 'Past',
        TimelineBand.today => 'Today',
        TimelineBand.upcoming => 'Upcoming',
      };
}

/// Month currently shown by the timeline stepper.
final timelineMonthProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month + ref.watch(timelineMonthOffsetProvider));
});

/// Past / Today / Upcoming, each grouped by day, scoped to the visible month.
/// Empty sections are dropped.
final timelineSectionsProvider = Provider<List<TimelineSection>>((ref) {
  final tasks = ref.watch(labelFilteredTasksProvider);
  final month = ref.watch(timelineMonthProvider);
  final now = DateTime.now();
  final today = AppDates.dateOnly(now);

  final inMonth = tasks.where((t) =>
      t.startDateTime.year == month.year && t.startDateTime.month == month.month);

  final byBand = <TimelineBand, Map<DateTime, List<Task>>>{
    TimelineBand.past: {},
    TimelineBand.today: {},
    TimelineBand.upcoming: {},
  };

  for (final task in inMonth) {
    final day = AppDates.dateOnly(task.startDateTime);
    final band = day.isBefore(today)
        ? TimelineBand.past
        : day.isAtSameMomentAs(today)
            ? TimelineBand.today
            : TimelineBand.upcoming;
    byBand[band]!.putIfAbsent(day, () => []).add(task);
  }

  return [
    for (final band in TimelineBand.values)
      if (byBand[band]!.isNotEmpty)
        TimelineSection(
          band: band,
          groups: (byBand[band]!.keys.toList()
                // Past reads newest-first, everything else oldest-first.
                ..sort((a, b) => band == TimelineBand.past
                    ? b.compareTo(a)
                    : a.compareTo(b)))
              .map((day) => TimelineGroup(
                    date: day,
                    tasks: byBand[band]![day]!
                      ..sort((a, b) =>
                          a.startDateTime.compareTo(b.startDateTime)),
                  ))
              .toList(),
        ),
  ];
});
