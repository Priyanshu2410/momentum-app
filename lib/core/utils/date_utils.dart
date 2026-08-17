import 'package:intl/intl.dart';

import '../../domain/entities/task.dart';
import '../../domain/enums/repeat_type.dart';

/// Date formatting and recurrence maths. Pure — no Flutter, no DB.
class AppDates {
  const AppDates._();

  static final _time = DateFormat('HH:mm');
  static final _day = DateFormat('MMM d');
  static final _dayShort = DateFormat('MMM d, EEE');
  static final _weekday = DateFormat('EEEE');
  static final _month = DateFormat('MMMM yyyy');
  static final _full = DateFormat('MMM d, yyyy');

  /// "09:30"
  static String time(DateTime d) => _time.format(d);

  /// "Aug 16"
  static String day(DateTime d) => _day.format(d);

  /// "Aug 16, Mon"
  static String dayWithWeekday(DateTime d) => _dayShort.format(d);

  /// "Friday · Aug 15" — the header eyebrow.
  static String eyebrow(DateTime d) => '${_weekday.format(d)} · ${_day.format(d)}';

  /// "August 2025" — the timeline month stepper.
  static String month(DateTime d) => _month.format(d);

  /// "Aug 16, 2025 · 09:30" — detail-sheet field values.
  static String full(DateTime d) => '${_full.format(d)} · ${_time.format(d)}';

  /// Plain-words start time: "Now", "Today, 14:30", "Tomorrow, 09:00",
  /// "Mon, 09:00", "Aug 24, 09:00". The scheduling UI reads this everywhere
  /// rather than making people decode a bare timestamp.
  static String whenLabel(DateTime when, DateTime now) {
    if (!when.isAfter(now)) return 'Now';
    if (isSameDay(when, now)) return 'Today, ${time(when)}';
    if (isSameDay(when, now.add(const Duration(days: 1)))) {
      return 'Tomorrow, ${time(when)}';
    }
    if (when.difference(now).inDays < 6) {
      return '${DateFormat('EEE').format(when)}, ${time(when)}';
    }
    return '${day(when)}, ${time(when)}';
  }

  /// Start-time shortcuts, newest-first. Past options are dropped, so the list
  /// never offers a time that has already gone.
  static List<(String, DateTime)> startPresets(DateTime now) {
    final tonight = DateTime(now.year, now.month, now.day, 18);
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9);
    return [
      ('Start now', now),
      ('In 1 hour', now.add(const Duration(hours: 1))),
      if (tonight.isAfter(now.add(const Duration(hours: 1)))) ('This evening', tonight),
      ('Tomorrow morning', tomorrow),
      ('Next week', DateTime(now.year, now.month, now.day + 7, 9)),
    ];
  }

  /// Due-time shortcuts, all measured from [start] so a due date can never
  /// land before the task begins.
  static List<(String, DateTime)> duePresets(DateTime start) {
    return [
      ('1 hour after start', start.add(const Duration(hours: 1))),
      ('3 hours after start', start.add(const Duration(hours: 3))),
      ('End of that day', DateTime(start.year, start.month, start.day, 23, 59)),
      ('Next day', start.add(const Duration(days: 1))),
      ('In a week', start.add(const Duration(days: 7))),
    ];
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Timeline group heading: "Today · Aug 15" or "Aug 20, Fri".
  static String groupHeading(DateTime d, DateTime now) =>
      isSameDay(d, now) ? 'Today · ${day(d)}' : dayWithWeekday(d);

  /// "now" / "10m ago" / "3h ago" / "Yesterday 14:00" / "Aug 10".
  static String relative(DateTime then, DateTime now) {
    final diff = now.difference(then);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (isSameDay(then, now)) return '${diff.inHours}h ago';
    final yesterday = now.subtract(const Duration(days: 1));
    if (isSameDay(then, yesterday)) return 'Yesterday ${time(then)}';
    return day(then);
  }

  /// 08:00 the following morning — the "Tomorrow morning" snooze preset.
  static DateTime tomorrowMorning(DateTime now) {
    final d = now.add(const Duration(days: 1));
    return DateTime(d.year, d.month, d.day, 8);
  }

  /// Adds months while clamping the day, so Jan 31 + 1 month is Feb 28/29
  /// rather than rolling into March.
  static DateTime addMonths(DateTime d, int months) {
    final total = d.month - 1 + months;
    final year = d.year + (total ~/ 12);
    final month = total % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(
      year,
      month,
      d.day > lastDay ? lastDay : d.day,
      d.hour,
      d.minute,
      d.second,
    );
  }

  /// Dart weekdays run Mon=1..Sun=7. The design's day picker is Sunday-first
  /// and 0-indexed, so `repeatConfig['days']` uses 0=Sunday.
  static int weekdayIndex(DateTime d) => d.weekday % 7;

  /// The next start time after [task.startDateTime], or null when the task
  /// does not repeat.
  static DateTime? nextOccurrence(Task task) =>
      nextOccurrenceFrom(task.startDateTime, task.repeatType, task.repeatConfig);

  /// Same rule, expressed over raw values so it can be applied repeatedly when
  /// a recurring task is completed long after it was due.
  static DateTime? nextOccurrenceFrom(
    DateTime from,
    RepeatType type,
    Map<String, dynamic>? config,
  ) {
    switch (type) {
      case RepeatType.none:
        return null;

      case RepeatType.daily:
        return from.add(const Duration(days: 1));

      case RepeatType.weekly:
        final days = _dayList(config);
        if (days.isEmpty) return from.add(const Duration(days: 7));
        // Walk forward to the next selected weekday.
        for (var i = 1; i <= 7; i++) {
          final candidate = from.add(Duration(days: i));
          if (days.contains(weekdayIndex(candidate))) return candidate;
        }
        return from.add(const Duration(days: 7));

      case RepeatType.monthly:
        return addMonths(from, 1);

      case RepeatType.custom:
        final interval = (config?['interval'] as num?)?.toInt() ?? 1;
        final n = interval < 1 ? 1 : interval;
        return switch (config?['unit'] as String?) {
          'days' => from.add(Duration(days: n)),
          'months' => addMonths(from, n),
          _ => from.add(Duration(days: n * 7)), // weeks
        };
    }
  }

  static Set<int> _dayList(Map<String, dynamic>? config) {
    final raw = config?['days'];
    if (raw is! List) return const {};
    return raw.whereType<num>().map((n) => n.toInt() % 7).toSet();
  }
}
