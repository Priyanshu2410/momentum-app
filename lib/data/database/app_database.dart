import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/notifications_dao.dart';
import 'daos/tasks_dao.dart';
import 'tables/notification_logs_table.dart';
import 'tables/tasks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Tasks, NotificationLogs],
  daos: [TasksDao, NotificationsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory instance for tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'momentum.sqlite'));
    // createInBackground keeps SQLite work off the UI isolate.
    return NativeDatabase.createInBackground(file);
  });
}
