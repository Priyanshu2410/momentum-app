import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Dark only. The v2 design ships no light palette and its Settings sheet has
/// no theme switch, so there is nothing to toggle between.
class AppTheme {
  const AppTheme._();

  static const systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accent,
      onSecondary: AppColors.onAccent,
      surface: AppColors.surface1,
      onSurface: AppColors.textPrimary,
      error: AppColors.statusOverdue,
      onError: AppColors.onAccent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      fontFamily: AppTypography.fontFamily,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: AppColors.border,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionColor: AppColors.accentTint,
        selectionHandleColor: AppColors.accent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface1,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalBarrierColor: Color(0x99000000), // rgba(0,0,0,0.6)
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surface2,
        contentTextStyle: AppTypography.notification,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
