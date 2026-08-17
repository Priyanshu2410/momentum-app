import 'package:flutter/widgets.dart';

class AppSpacing {
  const AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;

  static const screenPadding = EdgeInsets.symmetric(horizontal: xl);
  static const cardPadding = EdgeInsets.fromLTRB(15, 15, 15, 14);
  static const cardPaddingCompact = EdgeInsets.all(14);

  /// Bottom nav (84) + FAB overhang, so the last card clears both.
  static const listBottomInset = 150.0;

  static const navHeight = 84.0;
  static const fabSize = 56.0;
  static const fabBottom = 98.0;

  /// Board column width and gutter at the 402pt reference device.
  static const boardColumnWidth = 292.0;
  static const boardColumnGap = 12.0;
}

class AppRadius {
  const AppRadius._();

  static const card = BorderRadius.all(Radius.circular(16));
  static const control = BorderRadius.all(Radius.circular(14));
  static const notification = BorderRadius.all(Radius.circular(12));
  static const day = BorderRadius.all(Radius.circular(9));
  static const sheet = BorderRadius.vertical(top: Radius.circular(22));
  static const pill = BorderRadius.all(Radius.circular(999));
}
