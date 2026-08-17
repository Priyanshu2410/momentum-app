import '../entities/app_notification.dart';
import '../entities/task.dart';
import '../enums/repeat_type.dart';
import '../enums/task_label.dart';
import '../enums/task_priority.dart';
import '../enums/task_status.dart';

/// Contract the presentation layer talks to. Keeps Drift out of the widgets.
abstract interface class ITaskRepository {
  /// Live list of every non-deleted task, newest start first.
  Stream<List<Task>> watchTasks();

  Stream<List<AppNotification>> watchNotifications();

  Future<Task?> findTask(int id);

  /// Returns the created task (with its assigned id) so the caller can
  /// schedule notifications for it.
  Future<Task> createTask({
    required String title,
    required DateTime startDateTime,
    String? description,
    DateTime? dueDateTime,
    TaskPriority priority = TaskPriority.medium,
    TaskLabel label = TaskLabel.personal,
    RepeatType repeatType = RepeatType.none,
    Map<String, dynamic>? repeatConfig,
  });

  Future<void> updateTask(Task task);

  /// Marks done, cancels pending notifications and — when the task repeats —
  /// inserts the next occurrence.
  Future<void> completeTask(Task task);

  Future<void> setStatus(Task task, TaskStatus status);

  /// Pushes `startDateTime` out and reschedules. Demotes an in-progress task
  /// back to scheduled when the new start is in the future.
  Future<void> snoozeTask(Task task, DateTime newStart);

  /// Soft delete — the row stays for referential sanity, notifications go.
  Future<void> deleteTask(Task task);

  Future<void> markNotificationRead(int id);
  Future<void> markAllNotificationsRead();
  Future<void> clearNotifications();
}
