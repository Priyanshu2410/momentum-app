/// What caused a notification-log row. Drives the dot colour on the
/// Notifications screen.
enum NotificationKind {
  started('started'),
  dueSoon('due_soon'),
  overdue('overdue');

  const NotificationKind(this.dbValue);

  final String dbValue;

  static NotificationKind fromDb(String value) => values.firstWhere(
        (k) => k.dbValue == value,
        orElse: () => NotificationKind.started,
      );
}

/// A dispatched notification, kept so the Notifications screen has history.
/// Local notifications can fire while the app is dead, so rows are written by
/// the scheduler when it makes the status change — not at OS delivery time.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.taskId,
    required this.message,
    required this.kind,
    required this.createdAt,
    required this.isRead,
  });

  final int id;
  final int taskId;
  final String message;
  final NotificationKind kind;
  final DateTime createdAt;
  final bool isRead;
}
