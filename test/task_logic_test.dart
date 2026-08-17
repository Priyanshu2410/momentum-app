import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/constants/notification_copy.dart';
import 'package:momentum/core/utils/date_utils.dart';
import 'package:momentum/domain/entities/app_notification.dart';
import 'package:momentum/domain/entities/task.dart';
import 'package:momentum/domain/enums/repeat_type.dart';
import 'package:momentum/domain/enums/task_label.dart';
import 'package:momentum/domain/enums/task_priority.dart';
import 'package:momentum/domain/enums/task_status.dart';
import 'package:momentum/services/task_scheduler_service.dart';
import 'package:momentum/services/update_service.dart';

Task _task({
  required TaskStatus status,
  required DateTime start,
  DateTime? due,
  RepeatType repeat = RepeatType.none,
  Map<String, dynamic>? config,
}) {
  return Task(
    id: 1,
    title: 'Test',
    status: status,
    priority: TaskPriority.medium,
    label: TaskLabel.personal,
    repeatType: repeat,
    repeatConfig: config,
    startDateTime: start,
    dueDateTime: due,
    createdAt: DateTime(2025),
  );
}

void main() {
  final now = DateTime(2025, 8, 15, 12);
  final past = now.subtract(const Duration(hours: 1));
  final future = now.add(const Duration(hours: 1));

  group('nextStatusFor', () {
    test('promotes a scheduled task once its start time has passed', () {
      final task = _task(status: TaskStatus.scheduled, start: past);
      expect(nextStatusFor(task, now), TaskStatus.inProgress);
    });

    test('leaves a scheduled task alone before its start time', () {
      final task = _task(status: TaskStatus.scheduled, start: future);
      expect(nextStatusFor(task, now), isNull);
    });

    test('never moves a completed task, even long past its due time', () {
      final task = _task(status: TaskStatus.done, start: past, due: past);
      expect(nextStatusFor(task, now), isNull);
    });

    test('expires an in-progress task once its due time has passed', () {
      final task = _task(status: TaskStatus.inProgress, start: past, due: past);
      expect(nextStatusFor(task, now), TaskStatus.overdue);
    });

    test('overdue wins when a task both started and expired', () {
      final task = _task(status: TaskStatus.scheduled, start: past, due: past);
      expect(nextStatusFor(task, now), TaskStatus.overdue);
    });

    test('does not re-flag a task that is already overdue', () {
      final task = _task(status: TaskStatus.overdue, start: past, due: past);
      expect(nextStatusFor(task, now), isNull);
    });

    test('ignores a due time that has not arrived yet', () {
      final task =
          _task(status: TaskStatus.inProgress, start: past, due: future);
      expect(nextStatusFor(task, now), isNull);
    });
  });

  group('nextOccurrence', () {
    test('returns null when the task does not repeat', () {
      expect(nextOccurrenceOf(RepeatType.none, DateTime(2025, 8, 15)), isNull);
    });

    test('daily steps one day', () {
      expect(
        nextOccurrenceOf(RepeatType.daily, DateTime(2025, 8, 15, 9, 30)),
        DateTime(2025, 8, 16, 9, 30),
      );
    });

    test('weekly with no day list steps a full week', () {
      expect(
        nextOccurrenceOf(RepeatType.weekly, DateTime(2025, 8, 15)),
        DateTime(2025, 8, 22),
      );
    });

    test('weekly hops to the next selected day', () {
      // Mon 6 Jan 2025, repeating Mon + Wed -> Wed 8 Jan.
      expect(
        nextOccurrenceOf(
          RepeatType.weekly,
          DateTime(2025, 1, 6),
          config: {'days': [1, 3]},
        ),
        DateTime(2025, 1, 8),
      );
    });

    test('weekly wraps around the end of the week', () {
      // Wed 8 Jan, repeating Mon + Wed -> Mon 13 Jan.
      expect(
        nextOccurrenceOf(
          RepeatType.weekly,
          DateTime(2025, 1, 8),
          config: {'days': [1, 3]},
        ),
        DateTime(2025, 1, 13),
      );
    });

    test('monthly clamps to the shorter month rather than overflowing', () {
      expect(
        nextOccurrenceOf(RepeatType.monthly, DateTime(2025, 1, 31, 8)),
        DateTime(2025, 2, 28, 8),
      );
    });

    test('custom honours interval and unit', () {
      expect(
        nextOccurrenceOf(
          RepeatType.custom,
          DateTime(2025, 8, 15),
          config: {'interval': 2, 'unit': 'weeks'},
        ),
        DateTime(2025, 8, 29),
      );
      expect(
        nextOccurrenceOf(
          RepeatType.custom,
          DateTime(2025, 8, 15),
          config: {'interval': 3, 'unit': 'days'},
        ),
        DateTime(2025, 8, 18),
      );
    });

    test('a corrupt config degrades instead of throwing', () {
      expect(
        nextOccurrenceOf(
          RepeatType.custom,
          DateTime(2025, 8, 15),
          config: {'interval': 0, 'unit': 'nonsense'},
        ),
        // interval floors at 1, unknown unit falls back to weeks
        DateTime(2025, 8, 22),
      );
    });
  });

  test('addMonths clamps the day to the target month length', () {
    expect(AppDates.addMonths(DateTime(2024, 1, 31), 1), DateTime(2024, 2, 29));
    expect(AppDates.addMonths(DateTime(2025, 12, 15), 1), DateTime(2026, 1, 15));
  });

  group('statusForStart', () {
    final now = DateTime(2025, 8, 16, 10);

    test('a start that has arrived means the task is running now', () {
      expect(statusForStart(now, now), TaskStatus.inProgress);
      expect(
        statusForStart(now.subtract(const Duration(minutes: 5)), now),
        TaskStatus.inProgress,
      );
    });

    test('only a future start parks the task in Scheduled', () {
      expect(
        statusForStart(now.add(const Duration(minutes: 1)), now),
        TaskStatus.scheduled,
      );
    });
  });

  group('scheduling copy', () {
    final now = DateTime(2025, 8, 16, 10);

    test('whenLabel says it in words', () {
      expect(AppDates.whenLabel(now, now), 'Now');
      expect(AppDates.whenLabel(now.subtract(const Duration(hours: 1)), now),
          'Now');
      expect(AppDates.whenLabel(DateTime(2025, 8, 16, 14, 30), now),
          'Today, 14:30');
      expect(AppDates.whenLabel(DateTime(2025, 8, 17, 9), now),
          'Tomorrow, 09:00');
      expect(AppDates.whenLabel(DateTime(2025, 9, 24, 9), now),
          'Sep 24, 09:00');
    });

    test('start presets never offer a time that has gone', () {
      final evening = DateTime(2025, 8, 16, 22);
      for (final (_, value) in AppDates.startPresets(evening)) {
        expect(value.isBefore(evening), isFalse);
      }
    });

    test('due presets all land after the start', () {
      final start = DateTime(2025, 8, 16, 23, 30);
      for (final (_, value) in AppDates.duePresets(start)) {
        expect(value.isAfter(start), isTrue, reason: '$value vs $start');
      }
    });
  });

  group('update check', () {
    test('compares versions numerically, not as strings', () {
      expect(UpdateService.isNewer('v1.10.0', '1.9.0'), isTrue);
      expect(UpdateService.isNewer('1.0.1', '1.0.0'), isTrue);
      expect(UpdateService.isNewer('1.1', '1.0.9'), isTrue);
      expect(UpdateService.isNewer('1.0.0', '1.0.0'), isFalse);
      expect(UpdateService.isNewer('1.0.0', '1.0.1'), isFalse);
      // A build suffix is not a version bump.
      expect(UpdateService.isNewer('1.0.0+9', '1.0.0+2'), isFalse);
      // A malformed tag must not throw during a background check.
      expect(UpdateService.isNewer('nonsense', '1.0.0'), isFalse);
    });

    test('takes the APK asset from a newer release', () {
      final update = UpdateService.parseRelease('''
        {"tag_name": "v1.2.0", "body": "Fixed the thing",
         "assets": [{"name": "notes.txt", "browser_download_url": "u/notes"},
                    {"name": "momentum-1.2.0.apk",
                     "browser_download_url": "u/momentum.apk"}]}
      ''', '1.1.0');
      expect(update, isNotNull);
      expect(update!.version, '1.2.0');
      expect(update.downloadUrl, 'u/momentum.apk');
      expect(update.notes, 'Fixed the thing');
    });

    test('ignores releases that are older, draft, or have no APK', () {
      const apk = '"assets": [{"name": "a.apk", '
          '"browser_download_url": "u"}]';
      expect(
        UpdateService.parseRelease('{"tag_name": "v1.0.0", $apk}', '1.0.0'),
        isNull,
      );
      expect(
        UpdateService.parseRelease(
            '{"tag_name": "v2.0.0", "draft": true, $apk}', '1.0.0'),
        isNull,
      );
      expect(
        UpdateService.parseRelease(
            '{"tag_name": "v2.0.0", "prerelease": true, $apk}', '1.0.0'),
        isNull,
      );
      expect(
        UpdateService.parseRelease('{"tag_name": "v2.0.0", "assets": []}', '1.0.0'),
        isNull,
      );
    });
  });

  group('notification copy', () {
    test('escapes a title before it reaches the HTML big-text body', () {
      final copy = NotificationCopy.forKind(
          NotificationKind.started, 'Ship <b>v2</b> & rest', 1);
      expect(copy.bigText, contains('Ship &lt;b&gt;v2&lt;/b&gt; &amp; rest'));
      expect(copy.bigText, isNot(contains('<b>v2')));
      // The collapsed title is not HTML-parsed, so it stays readable.
      expect(copy.title, contains('Ship <b>v2</b> & rest'));
    });

    test('the quote is stable for a task, and differs per kind', () {
      final a = NotificationCopy.forKind(NotificationKind.started, 'x', 7);
      final b = NotificationCopy.forKind(NotificationKind.started, 'x', 7);
      final c = NotificationCopy.forKind(NotificationKind.overdue, 'x', 7);
      expect(a.bigText, b.bigText);
      expect(a.bigText, isNot(c.bigText));
    });

    test('every kind carries a quote and a summary', () {
      for (final kind in NotificationKind.values) {
        final copy = NotificationCopy.forKind(kind, 'Task', 3);
        expect(copy.bigText, contains('“'));
        expect(copy.summary, isNotEmpty);
        expect(copy.ticker, isNotEmpty);
      }
    });
  });
}

DateTime? nextOccurrenceOf(
  RepeatType type,
  DateTime from, {
  Map<String, dynamic>? config,
}) =>
    AppDates.nextOccurrenceFrom(from, type, config);
