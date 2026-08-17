import 'package:drift/drift.dart';

@DataClassName('TaskRow')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();

  /// 'in_progress' | 'overdue' | 'scheduled' | 'done'
  TextColumn get status => text().withDefault(const Constant('scheduled'))();

  /// 'high' | 'medium' | 'low'
  TextColumn get priority => text().withDefault(const Constant('medium'))();

  /// 'work' | 'personal' | 'health' | 'finance' | 'other'
  TextColumn get label => text().withDefault(const Constant('personal'))();

  /// 'none' | 'daily' | 'weekly' | 'monthly' | 'custom'
  TextColumn get repeatType => text().withDefault(const Constant('none'))();

  /// JSON, e.g. {"interval": 2, "unit": "weeks"} or {"days": [1, 3]}
  TextColumn get repeatConfig => text().nullable()();

  DateTimeColumn get startDateTime => dateTime()();
  DateTimeColumn get dueDateTime => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Mirrors of `Task.startNotificationId` / `dueNotificationId`. The ids are
  /// derived from the row id, so these are written for inspectability rather
  /// than read back at cancel time.
  IntColumn get startNotificationId => integer().nullable()();
  IntColumn get dueNotificationId => integer().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
