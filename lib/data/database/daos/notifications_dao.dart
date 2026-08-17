import 'package:drift/drift.dart';

import '../../../domain/entities/app_notification.dart';
import '../app_database.dart';
import '../tables/notification_logs_table.dart';

part 'notifications_dao.g.dart';

@DriftAccessor(tables: [NotificationLogs])
class NotificationsDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationsDaoMixin {
  NotificationsDao(super.db);

  Stream<List<AppNotification>> watchAll() => (select(notificationLogs)
        ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
      .watch()
      .map((rows) => rows.map(_toDomain).toList());

  /// [at] is the moment the event actually happened, not the moment the
  /// scheduler noticed it — background runs can be up to 15 minutes late and
  /// the relative timestamps would otherwise read wrong.
  Future<void> log({
    required int taskId,
    required String message,
    required NotificationKind kind,
    DateTime? at,
  }) =>
      into(notificationLogs).insert(
        NotificationLogsCompanion.insert(
          taskId: taskId,
          message: message,
          kind: kind.dbValue,
          createdAt: Value(at ?? DateTime.now()),
        ),
      );

  Future<void> markRead(int id) =>
      (update(notificationLogs)..where((n) => n.id.equals(id)))
          .write(const NotificationLogsCompanion(isRead: Value(true)));

  Future<void> markAllRead() => update(notificationLogs)
      .write(const NotificationLogsCompanion(isRead: Value(true)));

  Future<void> clear() => delete(notificationLogs).go();

  /// Drops log rows for a task that has been deleted.
  Future<void> deleteForTask(int taskId) =>
      (delete(notificationLogs)..where((n) => n.taskId.equals(taskId))).go();
}

AppNotification _toDomain(NotificationLogRow r) => AppNotification(
      id: r.id,
      taskId: r.taskId,
      message: r.message,
      kind: NotificationKind.fromDb(r.kind),
      createdAt: r.createdAt,
      isRead: r.isRead,
    );
