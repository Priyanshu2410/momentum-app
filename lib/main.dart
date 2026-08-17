import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'core/settings/settings_service.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/providers/ui_feedback_provider.dart';
import 'services/notification_service.dart';
import 'services/task_scheduler_service.dart';

const taskPromoterTask = 'taskPromoterTask';

/// Runs in its own isolate, so it opens its own database and closes it again.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((_, __) async {
    final db = AppDatabase();
    try {
      final notifications = NotificationService();
      await notifications.initialize();
      final settings = await const SettingsService().read();
      await TaskSchedulerService(db, notifications).sync(settings: settings);
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[workmanager] pass failed: $e');
    } finally {
      await db.close();
    }
    return true;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlay);

  final notifications = NotificationService();
  await notifications.initialize();
  await notifications.requestPermissions();

  // If a notification launched the app, open that task once the shell is up.
  final launchTaskId = await notifications.launchTaskId();

  await _registerBackgroundPromotion();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notifications),
        if (launchTaskId != null)
          pendingTaskIdProvider.overrideWith((ref) => launchTaskId),
      ],
      child: const MomentumApp(),
    ),
  );
}

/// Android only. iOS background execution is not dependable enough to promote
/// tasks on, so there it relies on the resume-time pass plus the notifications
/// already handed to the OS.
Future<void> _registerBackgroundPromotion() async {
  if (!Platform.isAndroid) return;
  try {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      taskPromoterTask,
      taskPromoterTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  } on Object catch (e) {
    if (kDebugMode) debugPrint('[workmanager] registration failed: $e');
  }
}
