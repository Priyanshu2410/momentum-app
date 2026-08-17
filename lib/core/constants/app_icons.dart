import 'package:flutter/material.dart';

/// The design draws its own 1.4–1.6px stroked SVGs. These are the closest
/// Material outlines — same glyph, same weight family, no hand-rolled paths.
class AppIcons {
  const AppIcons._();

  static const settings = Icons.settings_outlined;
  static const clock = Icons.schedule_outlined;
  static const calendar = Icons.calendar_today_outlined;
  static const flag = Icons.outlined_flag;
  static const tag = Icons.sell_outlined;
  static const repeat = Icons.repeat_rounded;
  static const check = Icons.check_circle_outline_rounded;
  static const snooze = Icons.refresh_rounded;
  static const delete = Icons.delete_outline_rounded;
  static const close = Icons.close_rounded;
  static const plus = Icons.add_rounded;
  static const chevronLeft = Icons.chevron_left_rounded;
  static const chevronRight = Icons.chevron_right_rounded;

  // Bottom navigation
  static const home = Icons.grid_view_rounded;
  static const timeline = Icons.subject_rounded;
  static const bell = Icons.notifications_none_rounded;
  static const bellFilled = Icons.notifications_rounded;

  // List / board toggle
  static const listView = Icons.subject_rounded;
  static const boardView = Icons.view_week_outlined;
}
