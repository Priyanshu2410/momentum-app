import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/notification_copy.dart';
import '../domain/entities/app_notification.dart';
import '../domain/entities/task.dart';

/// Fires when a notification is tapped while the app is running. `main.dart`
/// also drains the launch payload on cold start.
@pragma('vm:entry-point')
void _onBackgroundResponse(NotificationResponse response) {
  // Nothing to do from the background isolate — the payload is re-read from
  // getNotificationAppLaunchDetails() when the app comes up.
}

/// Schedules, cancels and dispatches local notifications.
///
/// Two notifications are scheduled per task, using the ids derived from the
/// row id so cancellation never needs a DB read:
///   * `task.id * 2`     — at `startDateTime`
///   * `task.id * 2 + 1` — 30 minutes before `dueDateTime`
///
/// The overdue message is not pre-scheduled: it is shown by
/// [TaskSchedulerService] at the moment it flips the status, which is the only
/// point where "still not done" is actually known.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'momentum_tasks';
  static const _channelName = 'Task reminders';
  static const _channelDescription =
      'Reminders when your tasks start and approach their due time.';

  /// Task id of the most recently tapped notification, or null. The shell
  /// watches this to deep-link into the detail sheet.
  final ValueNotifier<int?> tappedTaskId = ValueNotifier<int?>(null);

  bool _ready = false;

  Future<void> initialize() async {
    if (_ready) return;
    await _initTimezone();

    const settings = InitializationSettings(
      // A monochrome silhouette — Android draws the small icon as a mask, so
      // the full-colour launcher PNG came out as a grey blob.
      android: AndroidInitializationSettings('@drawable/ic_notification'),
      iOS: DarwinInitializationSettings(
        // Requested explicitly below so the prompt is not tied to startup.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (r) => _handleTap(r.payload),
      onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );

    _ready = true;
  }

  /// Safe to call more than once; the OS only prompts the first time.
  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Task id the app was cold-started with, if it was launched by a tap.
  Future<int?> launchTaskId() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return int.tryParse(details?.notificationResponse?.payload ?? '');
  }

  /// Cancels whatever is pending for the task and schedules a fresh pair.
  /// This is the only method callers need after a create or an edit.
  Future<void> rescheduleForTask(Task task) async {
    await cancelTaskNotifications(task.id);
    if (task.isDone) return;
    await scheduleStartNotification(task);
    await scheduleDueNotification(task);
  }

  Future<void> scheduleStartNotification(Task task) => _schedule(
        id: task.startNotificationId,
        taskId: task.id,
        copy: NotificationCopy.forKind(
            NotificationKind.started, task.title, task.id),
        when: task.startDateTime,
      );

  /// 30 minutes ahead of the due time, per the design's "due soon" reminder.
  Future<void> scheduleDueNotification(Task task) async {
    final due = task.dueDateTime;
    if (due == null) return;
    await _schedule(
      id: task.dueNotificationId,
      taskId: task.id,
      copy: NotificationCopy.forKind(
          NotificationKind.dueSoon, task.title, task.id),
      when: due.subtract(const Duration(minutes: 30)),
    );
  }

  /// Shown immediately by the scheduler when a task tips into overdue.
  Future<void> showOverdueNow(Task task) async {
    final copy = NotificationCopy.forKind(
        NotificationKind.overdue, task.title, task.id);
    try {
      await _plugin.show(
        task.dueNotificationId,
        copy.title,
        copy.body,
        _detailsFor(copy),
        payload: '${task.id}',
      );
    } on Object catch (e) {
      _log('showOverdueNow failed for ${task.id}: $e');
    }
  }

  /// Fixed id for the daily digest. Task ids derive theirs from the row id
  /// (`id * 2` and `id * 2 + 1`), so this sits far above any of them.
  static const digestNotificationId = 900001;

  /// Daily "what is still open" summary at [minutesSinceMidnight].
  ///
  /// Re-armed on every scheduler pass rather than left to repeat forever, so
  /// the listed tasks are current — a notification handed to the OS carries
  /// fixed text, and a week-old summary would be worse than none.
  Future<void> scheduleDailyDigest({
    required int minutesSinceMidnight,
    required int openCount,
    required List<String> titles,
  }) async {
    await cancelDailyDigest();
    // Nothing open is not worth a buzz.
    if (openCount == 0) return;

    final now = DateTime.now();
    var when = DateTime(now.year, now.month, now.day,
        minutesSinceMidnight ~/ 60, minutesSinceMidnight % 60);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));

    final copy = NotificationCopy.digest(
      openCount,
      titles,
      _dayOfYear(when),
    );

    try {
      await _plugin.zonedSchedule(
        digestNotificationId,
        copy.title,
        copy.body,
        tz.TZDateTime.from(when, tz.local),
        _detailsFor(copy),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on Object catch (e) {
      _log('digest schedule failed: $e');
    }
  }

  Future<void> cancelDailyDigest() async {
    try {
      await _plugin.cancel(digestNotificationId);
    } on Object catch (e) {
      _log('digest cancel failed: $e');
    }
  }

  static int _dayOfYear(DateTime d) =>
      d.difference(DateTime(d.year)).inDays;

  Future<void> cancelTaskNotifications(int taskId) async {
    try {
      await _plugin.cancel(taskId * 2);
      await _plugin.cancel(taskId * 2 + 1);
    } on Object catch (e) {
      _log('cancel failed for $taskId: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } on Object catch (e) {
      _log('cancelAll failed: $e');
    }
  }

  // ---------------------------------------------------------------- internals

  Future<void> _schedule({
    required int id,
    required int taskId,
    required NotificationCopy copy,
    required DateTime when,
  }) async {
    // A time that has already passed would fire instantly — skip it.
    if (!when.isAfter(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id,
        copy.title,
        copy.body,
        tz.TZDateTime.from(when, tz.local),
        _detailsFor(copy),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '$taskId',
      );
    } on Object catch (e) {
      // Never crash the app over a reminder — a missing exact-alarm permission
      // throws here on Android 14+.
      _log('schedule $id failed: $e');
    }
  }

  /// Expanded card: brand mark on the right, teal accent on the app name, and
  /// the quote in the big-text body. Built per notification because the style
  /// carries the copy.
  static NotificationDetails _detailsFor(NotificationCopy copy) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        color: const Color(0xFF3FD6B4), // AppColors.accent
        // Not @mipmap/ic_launcher: on API 26+ that resolves to the adaptive
        // icon XML, which BitmapFactory cannot decode — the badge would just
        // not appear. This one is always a PNG.
        largeIcon: const DrawableResourceAndroidBitmap(
            '@drawable/ic_notification_large'),
        ticker: copy.ticker,
        category: AndroidNotificationCategory.reminder,
        styleInformation: BigTextStyleInformation(
          copy.bigText,
          htmlFormatBigText: true,
          contentTitle: copy.title,
          summaryText: copy.summary,
          htmlFormatSummaryText: true,
        ),
      ),
      iOS: DarwinNotificationDetails(subtitle: copy.summary),
    );
  }

  Future<void> _initTimezone() async {
    tz_data.initializeTimeZones();
    try {
      // flutter_timezone 5.x returns a TimezoneInfo; the IANA name is on it.
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } on Object catch (e) {
      _log('timezone lookup failed, falling back to UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }
  }

  void _handleTap(String? payload) {
    final id = int.tryParse(payload ?? '');
    if (id != null) tappedTaskId.value = id;
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[notifications] $message');
  }
}
