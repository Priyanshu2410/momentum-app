import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles from the design. `letterSpacing` is in logical pixels, so the
/// design's em values are pre-multiplied by the font size here.
class AppTypography {
  const AppTypography._();

  /// Falls back to the platform font until the TTFs are added (see SETUP.md).
  static const fontFamily = 'Space Grotesk';

  /// "FRIDAY · AUG 15"
  static const eyebrow = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.54, // 0.14em
    color: AppColors.textMuted,
  );

  /// "Today"
  static const headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 27,
    height: 1,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.81, // -0.03em
    color: AppColors.textPrimary,
  );

  /// "Notifications", "Repeat"
  static const screenTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 21,
    height: 1,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.42, // -0.02em
    color: AppColors.textPrimary,
  );

  /// "IN PROGRESS", "TODAY"
  static const sectionHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.54, // 0.14em
    color: AppColors.textSecondary,
  );

  /// List card title.
  static const cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.5,
    height: 1.35,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.155,
    color: AppColors.textPrimary,
  );

  /// Board / timeline card title (half a point smaller).
  static const cardTitleCompact = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.15,
    color: AppColors.textPrimary,
  );

  /// Time next to the clock glyph.
  static const cardMeta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Day text, counts — the quietest meta.
  static const meta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  /// Label chips, status pills, column counts.
  static const chip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1,
    fontWeight: FontWeight.w500,
  );

  /// Filter pills, repeat rows.
  static const pill = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w500,
  );

  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1,
    fontWeight: FontWeight.w600,
    color: AppColors.onAccent,
  );

  static const statValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 21,
    height: 1,
    fontWeight: FontWeight.w600,
  );

  static const statLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.44, // 0.04em
    color: AppColors.textSecondary,
  );

  /// Detail-sheet field name.
  static const fieldLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Detail-sheet field value.
  static const fieldValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1,
    fontWeight: FontWeight.w500,
  );

  /// Detail-sheet title, inline-editable.
  static const sheetTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  /// Quick-add title input.
  static const input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 19,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Notification row text.
  static const notification = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
}
