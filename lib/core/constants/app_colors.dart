import 'package:flutter/material.dart';

import '../../domain/enums/task_label.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_status.dart';

/// Every colour in the app. Values are taken verbatim from `Momentum v2.dc.html`.
class AppColors {
  const AppColors._();

  // Surfaces
  static const background = Color(0xFF0A0A0C);
  static const surface1 = Color(0xFF131316);
  static const surface2 = Color(0xFF1A1A1F);
  static const surface3 = Color(0xFF232329);

  // Lines
  static const border = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const borderStrong = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const hairline = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)

  // Accent
  static const accent = Color(0xFF3FD6B4);
  static const accentTint = Color(0x1F3FD6B4); // 12%
  static const accentEdge = Color(0x733FD6B4); // 45%
  static const accentSoft = Color(0x243FD6B4); // 14%
  static const onAccent = Color(0xFF06110E);

  // Text
  static const textPrimary = Color(0xFFE9EDEB);
  static const textSecondary = Color(0xFF85898C);
  static const textMuted = Color(0xFF4B4E50);

  // Status
  static const statusInProgress = accent;
  static const statusOverdue = Color(0xFFFF6B6B);
  static const statusScheduled = Color(0xFF7C89FF);
  static const statusDone = Color(0xFF8A8F98);

  // Priority
  static const priorityHigh = Color(0xFFFF6B6B);
  static const priorityMedium = Color(0xFFF0B67F);
  static const priorityLow = Color(0xFF8A8F98);

  // Labels
  static const labelWork = Color(0xFF7C89FF);
  static const labelPersonal = Color(0xFFC08CFF);
  static const labelHealth = Color(0xFF3FD6B4);
  static const labelFinance = Color(0xFFF0B67F);
  static const labelOther = Color(0xFF85898C);

  /// Card background for an overdue task — a barely-there red wash.
  static const overdueCard = Color(0x0BFF6B6B); // rgba(255,107,107,0.045)
}

extension TaskStatusStyle on TaskStatus {
  Color get color => switch (this) {
        TaskStatus.inProgress => AppColors.statusInProgress,
        TaskStatus.overdue => AppColors.statusOverdue,
        TaskStatus.scheduled => AppColors.statusScheduled,
        TaskStatus.done => AppColors.statusDone,
      };

  /// Filled background when the status chip / stat card is active.
  Color get tint => switch (this) {
        TaskStatus.inProgress => const Color(0x1F3FD6B4), // 12%
        TaskStatus.overdue => const Color(0x1AFF6B6B), // 10%
        TaskStatus.scheduled => const Color(0x1F7C89FF), // 12%
        TaskStatus.done => const Color(0x0FFFFFFF), // 6% white
      };
}

extension TaskLabelStyle on TaskLabel {
  Color get color => switch (this) {
        TaskLabel.work => AppColors.labelWork,
        TaskLabel.personal => AppColors.labelPersonal,
        TaskLabel.health => AppColors.labelHealth,
        TaskLabel.finance => AppColors.labelFinance,
        TaskLabel.other => AppColors.labelOther,
      };

  Color get tint => switch (this) {
        TaskLabel.work => const Color(0x1F7C89FF),
        TaskLabel.personal => const Color(0x1FC08CFF),
        TaskLabel.health => const Color(0x1F3FD6B4),
        TaskLabel.finance => const Color(0x1FF0B67F),
        TaskLabel.other => const Color(0x0FFFFFFF),
      };
}

extension TaskPriorityStyle on TaskPriority {
  Color get color => switch (this) {
        TaskPriority.high => AppColors.priorityHigh,
        TaskPriority.medium => AppColors.priorityMedium,
        TaskPriority.low => AppColors.priorityLow,
      };
}
