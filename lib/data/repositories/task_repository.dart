import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/date_utils.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/repeat_type.dart';
import '../../domain/enums/task_label.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../services/notification_service.dart';
import '../../services/task_scheduler_service.dart';
import '../database/app_database.dart';
import '../database/daos/tasks_dao.dart';

/// Owns the write path: every mutation that changes *when* a task happens also
/// fixes up its notifications, so the two can never drift apart.
class TaskRepository implements ITaskRepository {
  TaskRepository(this._db, this._notifications);

  final AppDatabase _db;
  final NotificationService _notifications;

  /// A recurring task completed long after the fact would otherwise land its
  /// next occurrence in the past. Advance until it is ahead of now, with a cap
  /// so a malformed config can never spin forever.
  static const _maxOccurrenceSkips = 400;

  @override
  Stream<List<Task>> watchTasks() => _db.tasksDao.watchAll();

  @override
  Stream<List<AppNotification>> watchNotifications() =>
      _db.notificationsDao.watchAll();

  @override
  Future<Task?> findTask(int id) => _db.tasksDao.findById(id);

  @override
  Future<Task> createTask({
    required String title,
    required DateTime startDateTime,
    String? description,
    DateTime? dueDateTime,
    TaskPriority priority = TaskPriority.medium,
    TaskLabel label = TaskLabel.personal,
    RepeatType repeatType = RepeatType.none,
    Map<String, dynamic>? repeatConfig,
  }) async {
    final status = statusForStart(startDateTime, DateTime.now());

    final id = await _guard(
      'createTask',
      () => _db.tasksDao.insertTask(
        TasksCompanion.insert(
          title: title,
          startDateTime: startDateTime,
          description: Value(description),
          dueDateTime: Value(dueDateTime),
          status: Value(status.dbValue),
          priority: Value(priority.dbValue),
          label: Value(label.dbValue),
          repeatType: Value(repeatType.dbValue),
          repeatConfig: Value(encodeRepeatConfig(repeatConfig)),
        ),
      ),
    );

    final created = await _db.tasksDao.findById(id);
    if (created == null) {
      throw StateError('Task $id vanished immediately after insert');
    }
    await _notifications.rescheduleForTask(created);
    return created;
  }

  @override
  Future<void> updateTask(Task task) async {
    await _guard('updateTask', () => _db.tasksDao.updateTask(task));
    await _notifications.rescheduleForTask(task);
  }

  @override
  Future<void> setStatus(Task task, TaskStatus status) async {
    if (status.isDone) return completeTask(task);

    await _guard(
      'setStatus',
      () => _db.tasksDao.setStatus(task.id, status, completedAt: null),
    );
    // Re-open the notification window when a task comes back from Done.
    await _notifications
        .rescheduleForTask(task.copyWith(status: status, completedAt: null));
  }

  @override
  Future<void> completeTask(Task task) async {
    await _guard(
      'completeTask',
      () => _db.tasksDao.setStatus(
        task.id,
        TaskStatus.done,
        completedAt: DateTime.now(),
      ),
    );
    await _notifications.cancelTaskNotifications(task.id);
    if (task.repeats) await _createNextOccurrence(task);
  }

  @override
  Future<void> snoozeTask(Task task, DateTime newStart) async {
    // Keep the original start-to-due gap so a snooze never inverts the two.
    final gap = task.dueDateTime?.difference(task.startDateTime);
    final moved = task.copyWith(
      startDateTime: newStart,
      dueDateTime: gap == null ? null : newStart.add(gap),
      status: statusForStart(newStart, DateTime.now()),
      completedAt: null,
    );
    await updateTask(moved);
  }

  @override
  Future<void> deleteTask(Task task) async {
    await _guard('deleteTask', () => _db.tasksDao.softDelete(task.id));
    await _db.notificationsDao.deleteForTask(task.id);
    await _notifications.cancelTaskNotifications(task.id);
  }

  @override
  Future<void> markNotificationRead(int id) => _db.notificationsDao.markRead(id);

  @override
  Future<void> markAllNotificationsRead() => _db.notificationsDao.markAllRead();

  @override
  Future<void> clearNotifications() => _db.notificationsDao.clear();

  // ---------------------------------------------------------------- internals

  Future<void> _createNextOccurrence(Task task) async {
    final now = DateTime.now();
    var next = AppDates.nextOccurrence(task);
    var skips = 0;
    while (next != null && !next.isAfter(now) && skips++ < _maxOccurrenceSkips) {
      next = AppDates.nextOccurrenceFrom(next, task.repeatType, task.repeatConfig);
    }
    if (next == null || !next.isAfter(now)) return;

    final gap = task.dueDateTime?.difference(task.startDateTime);
    await createTask(
      title: task.title,
      description: task.description,
      startDateTime: next,
      dueDateTime: gap == null ? null : next.add(gap),
      priority: task.priority,
      label: task.label,
      repeatType: task.repeatType,
      repeatConfig: task.repeatConfig,
    );
  }

  /// Logs in debug and rethrows. Swallowing a failed write would leave the UI
  /// showing state that was never persisted.
  Future<T> _guard<T>(String op, Future<T> Function() body) async {
    try {
      return await body();
    } on Object catch (e, st) {
      if (kDebugMode) debugPrint('[db] $op failed: $e\n$st');
      rethrow;
    }
  }
}
