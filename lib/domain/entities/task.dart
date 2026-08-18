import 'dart:convert';

import '../enums/repeat_type.dart';
import '../enums/task_label.dart';
import '../enums/task_priority.dart';
import '../enums/task_status.dart';

/// Sentinel so `copyWith` can tell "leave it alone" apart from "set to null".
const Object _unset = Object();

/// Pure Dart task model. No Drift, no Flutter — safe to use from the
/// workmanager background isolate and from tests.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.label,
    required this.repeatType,
    required this.startDateTime,
    required this.createdAt,
    this.description,
    this.repeatConfig,
    this.dueDateTime,
    this.completedAt,
  });

  final int id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskLabel label;
  final RepeatType repeatType;

  /// Decoded from the `repeatConfig` JSON column.
  /// Weekly: `{"days": [1, 3]}` (0 = Sunday).
  /// Custom: `{"interval": 2, "unit": "weeks"}`.
  final Map<String, dynamic>? repeatConfig;

  final DateTime startDateTime;
  final DateTime? dueDateTime;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// Notification ids are derived from the row id, so a task can always cancel
  /// its own pending notifications without reading them back first.
  int get startNotificationId => id * 2;
  int get dueNotificationId => id * 2 + 1;

  bool get isDone => status.isDone;
  bool get repeats => repeatType.repeats;

  Task copyWith({
    String? title,
    Object? description = _unset,
    TaskStatus? status,
    TaskPriority? priority,
    TaskLabel? label,
    RepeatType? repeatType,
    Object? repeatConfig = _unset,
    DateTime? startDateTime,
    Object? dueDateTime = _unset,
    Object? completedAt = _unset,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      label: label ?? this.label,
      repeatType: repeatType ?? this.repeatType,
      repeatConfig: identical(repeatConfig, _unset)
          ? this.repeatConfig
          : repeatConfig as Map<String, dynamic>?,
      startDateTime: startDateTime ?? this.startDateTime,
      dueDateTime: identical(dueDateTime, _unset)
          ? this.dueDateTime
          : dueDateTime as DateTime?,
      createdAt: createdAt,
      completedAt: identical(completedAt, _unset)
          ? this.completedAt
          : completedAt as DateTime?,
    );
  }

  /// Full value equality, not just the id.
  ///
  /// Riverpod only notifies listeners when a provider's new value `!=` the old
  /// one. While this compared ids alone, an edited task looked identical to the
  /// one it replaced, so `taskByIdProvider` never fired and the detail sheet
  /// showed a stale status after you tapped one.
  @override
  bool operator ==(Object other) =>
      other is Task &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.status == status &&
      other.priority == priority &&
      other.label == label &&
      other.repeatType == repeatType &&
      other.startDateTime == startDateTime &&
      other.dueDateTime == dueDateTime &&
      other.createdAt == createdAt &&
      other.completedAt == completedAt &&
      // repeatConfig is JSON-decoded, so encoding both sides is a cheap deep
      // compare. A key-order difference would only cost one extra rebuild.
      jsonEncode(other.repeatConfig) == jsonEncode(repeatConfig);

  /// repeatConfig is deliberately left out — equal objects still hash equal,
  /// and a Map has no stable hash of its own.
  @override
  int get hashCode => Object.hash(id, title, description, status, priority,
      label, repeatType, startDateTime, dueDateTime, createdAt, completedAt);
}
