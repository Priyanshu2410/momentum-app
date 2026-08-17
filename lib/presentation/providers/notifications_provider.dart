import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../domain/entities/app_notification.dart';
import 'app_providers.dart';

final notificationsProvider = StreamProvider<List<AppNotification>>(
  (ref) => ref.watch(taskRepositoryProvider).watchNotifications(),
);

/// Drives the red dot on the bell.
final hasUnreadProvider = Provider<bool>((ref) {
  final items = ref.watch(notificationsProvider).valueOrNull ?? const [];
  return items.any((n) => !n.isRead);
});

class NotificationGroup {
  const NotificationGroup({required this.title, required this.items});

  final String title;
  final List<AppNotification> items;
}

/// Today / Yesterday / Earlier, newest first within each.
final groupedNotificationsProvider = Provider<List<NotificationGroup>>((ref) {
  final items = ref.watch(notificationsProvider).valueOrNull ?? const [];
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  final today = <AppNotification>[];
  final yday = <AppNotification>[];
  final earlier = <AppNotification>[];

  for (final n in items) {
    if (AppDates.isSameDay(n.createdAt, now)) {
      today.add(n);
    } else if (AppDates.isSameDay(n.createdAt, yesterday)) {
      yday.add(n);
    } else {
      earlier.add(n);
    }
  }

  return [
    if (today.isNotEmpty) NotificationGroup(title: 'Today', items: today),
    if (yday.isNotEmpty) NotificationGroup(title: 'Yesterday', items: yday),
    if (earlier.isNotEmpty) NotificationGroup(title: 'Earlier', items: earlier),
  ];
});
