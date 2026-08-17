import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../domain/entities/task.dart';
import '../../../domain/enums/repeat_type.dart';
import '../../../domain/enums/task_label.dart';
import '../../../domain/enums/task_priority.dart';
import '../../../domain/enums/task_status.dart';
import '../app_database.dart';
import '../tables/tasks_table.dart';

part 'tasks_dao.g.dart';

/// Every task query lives here. Returns domain entities, so nothing above the
/// data layer ever sees a Drift row.
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  Stream<List<Task>> watchAll() => (select(tasks)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.startDateTime)]))
      .watch()
      .map((rows) => rows.map(taskFromRow).toList());

  Future<List<Task>> allActive() async {
    final rows = await (select(tasks)..where((t) => t.isDeleted.equals(false)))
        .get();
    return rows.map(taskFromRow).toList();
  }

  Future<Task?> findById(int id) async {
    final row = await (select(tasks)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : taskFromRow(row);
  }

  /// Inserts and returns the row id, then backfills the derived notification
  /// ids in the same transaction.
  Future<int> insertTask(TasksCompanion companion) {
    return transaction(() async {
      final id = await into(tasks).insert(companion);
      await (update(tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          startNotificationId: Value(id * 2),
          dueNotificationId: Value(id * 2 + 1),
        ),
      );
      return id;
    });
  }

  Future<void> updateTask(Task task) =>
      (update(tasks)..where((t) => t.id.equals(task.id)))
          .write(companionFor(task));

  Future<void> setStatus(int id, TaskStatus status, {DateTime? completedAt}) =>
      (update(tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          status: Value(status.dbValue),
          completedAt: Value(completedAt),
        ),
      );

  Future<void> softDelete(int id) =>
      (update(tasks)..where((t) => t.id.equals(id)))
          .write(const TasksCompanion(isDeleted: Value(true)));
}

/// Row -> entity.
Task taskFromRow(TaskRow r) => Task(
      id: r.id,
      title: r.title,
      description: r.description,
      status: TaskStatus.fromDb(r.status),
      priority: TaskPriority.fromDb(r.priority),
      label: TaskLabel.fromDb(r.label),
      repeatType: RepeatType.fromDb(r.repeatType),
      repeatConfig: decodeRepeatConfig(r.repeatConfig),
      startDateTime: r.startDateTime,
      dueDateTime: r.dueDateTime,
      createdAt: r.createdAt,
      completedAt: r.completedAt,
    );

/// Entity -> companion, for full-row updates.
TasksCompanion companionFor(Task t) => TasksCompanion(
      title: Value(t.title),
      description: Value(t.description),
      status: Value(t.status.dbValue),
      priority: Value(t.priority.dbValue),
      label: Value(t.label.dbValue),
      repeatType: Value(t.repeatType.dbValue),
      repeatConfig: Value(encodeRepeatConfig(t.repeatConfig)),
      startDateTime: Value(t.startDateTime),
      dueDateTime: Value(t.dueDateTime),
      completedAt: Value(t.completedAt),
    );

/// Bad JSON in a config column degrades to "no config" rather than throwing —
/// the task still renders, it just loses its custom recurrence detail.
Map<String, dynamic>? decodeRepeatConfig(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}

String? encodeRepeatConfig(Map<String, dynamic>? config) =>
    (config == null || config.isEmpty) ? null : jsonEncode(config);
