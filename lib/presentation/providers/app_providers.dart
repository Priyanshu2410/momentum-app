import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings_service.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../services/notification_service.dart';
import '../../services/task_scheduler_service.dart';
import '../../services/update_service.dart';

/// Overridden in `main()` with the instance that was already initialized
/// before `runApp`, so the launch payload is not read twice.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('Override notificationServiceProvider in main()'),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsServiceProvider =
    Provider<SettingsService>((ref) => const SettingsService());

final updateServiceProvider =
    Provider<UpdateService>((ref) => const UpdateService());

final taskRepositoryProvider = Provider<ITaskRepository>(
  (ref) => TaskRepository(
    ref.watch(databaseProvider),
    ref.watch(notificationServiceProvider),
  ),
);

final taskSchedulerProvider = Provider<TaskSchedulerService>(
  (ref) => TaskSchedulerService(
    ref.watch(databaseProvider),
    ref.watch(notificationServiceProvider),
  ),
);
