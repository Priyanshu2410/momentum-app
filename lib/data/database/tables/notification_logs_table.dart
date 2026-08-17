import 'package:drift/drift.dart';

@DataClassName('NotificationLogRow')
class NotificationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer()();

  /// Rendered message, already containing the task title.
  /// Not named `text` — that would shadow `Table.text()`, the column builder.
  TextColumn get message => text()();

  /// 'started' | 'due_soon' | 'overdue'
  TextColumn get kind => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
}
