import 'package:flutter/foundation.dart';

import '../core/constants/app_strings.dart';
import '../core/settings/settings_service.dart';
import '../data/database/app_database.dart';
import '../domain/entities/app_notification.dart';
import '../domain/entities/task.dart';
import '../domain/enums/task_status.dart';
import 'notification_service.dart';

/// Status a task takes on when it is created, edited or snoozed: a start time
/// that has already arrived means the task is running *now*. Only a start in
/// the future parks it in Scheduled.
TaskStatus statusForStart(DateTime start, DateTime now) =>
    start.isAfter(now) ? TaskStatus.scheduled : TaskStatus.inProgress;

/// The whole auto-promotion rule, as one pure function.
///
/// Returns the status [task] ought to have at [now], or null to leave it be.
/// Overdue wins over starting: a task whose due time has already passed is
/// overdue even if it only just started.
TaskStatus? nextStatusFor(Task task, DateTime now) {
  // Done is terminal — nothing ever moves a completed task back.
  if (task.isDone) return null;

  final due = task.dueDateTime;
  if (due != null &&
      !due.isAfter(now) &&
      task.status != TaskStatus.overdue) {
    return TaskStatus.overdue;
  }

  if (task.status == TaskStatus.scheduled && !task.startDateTime.isAfter(now)) {
    return TaskStatus.inProgress;
  }

  return null;
}

/// Result of one pass, so the board can pulse the cards that just moved.
class SchedulerResult {
  const SchedulerResult({required this.promoted, required this.expired});

  const SchedulerResult.empty()
      : promoted = const [],
        expired = const [];

  final List<Task> promoted;
  final List<Task> expired;

  bool get changed => promoted.isNotEmpty || expired.isNotEmpty;
}

/// Walks every active task and applies [nextStatusFor]. Runs from three places:
/// the workmanager periodic job, `AppLifecycleState.resumed`, and app start.
class TaskSchedulerService {
  TaskSchedulerService(this._db, this._notifications);

  final AppDatabase _db;
  final NotificationService _notifications;

  Future<SchedulerResult> sync({
    required AppSettingsSnapshot settings,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final promoted = <Task>[];
    final expired = <Task>[];

    try {
      for (final task in await _db.tasksDao.allActive()) {
        final next = nextStatusFor(task, at);
        if (next == null) continue;

        // The Settings sheet's auto-promote switch only gates starting.
        // Falling overdue is a fact about the clock, not a promotion.
        if (next == TaskStatus.inProgress && !settings.autoPromote) continue;

        await _db.tasksDao.setStatus(task.id, next);

        if (next == TaskStatus.inProgress) {
          promoted.add(task);
          await _db.notificationsDao.log(
            taskId: task.id,
            message: AppStrings.startedLog(task.title),
            kind: NotificationKind.started,
            at: task.startDateTime,
          );
          // The start notification was already handed to the OS at create
          // time — nothing to fire here.
        } else {
          expired.add(task);
          await _db.notificationsDao.log(
            taskId: task.id,
            message: AppStrings.overdueLog(task.title),
            kind: NotificationKind.overdue,
            at: task.dueDateTime ?? at,
          );
          // Nothing was pre-scheduled for overdue, so show it now.
          if (settings.pushEnabled) await _notifications.showOverdueNow(task);
        }
      }
      await _armDailyDigest(settings);
    } on Object catch (e, st) {
      // A failed background pass must not take the app down; the next run
      // picks up whatever was missed.
      if (kDebugMode) debugPrint('[scheduler] sync failed: $e\n$st');
    }

    return SchedulerResult(promoted: promoted, expired: expired);
  }

  /// Re-arms the daily summary from the *current* set of in-progress tasks.
  ///
  /// A scheduled notification's text is fixed the moment the OS takes it, so a
  /// repeating one would read out whatever was open the day it was set. This
  /// runs on every pass — launch, resume, and the 15-minute job — so what it
  /// says is never more than one pass stale.
  Future<void> _armDailyDigest(AppSettingsSnapshot settings) async {
    final minutes = settings.digestMinutes;
    if (minutes == null || !settings.pushEnabled) {
      await _notifications.cancelDailyDigest();
      return;
    }

    final open = (await _db.tasksDao.allActive())
        .where((t) => t.status == TaskStatus.inProgress)
        .toList();

    await _notifications.scheduleDailyDigest(
      minutesSinceMidnight: minutes,
      openCount: open.length,
      // Three keeps the expanded card readable; the headline carries the total.
      titles: open.take(3).map((t) => t.title).toList(),
    );
  }
}
