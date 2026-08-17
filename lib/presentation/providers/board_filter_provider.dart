import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/task_label.dart';
import '../../domain/enums/task_status.dart';

enum HomeView { list, board }

enum AppTab { home, timeline, notifications }

/// The design's pill row: All, then four of the five labels. "Other" is
/// deliberately absent there — those tasks show under All.
final labelFilterProvider = StateProvider<TaskLabel?>((ref) => null);

/// Set by tapping a stat card. Tapping the active one clears it.
final statusFilterProvider = StateProvider<TaskStatus?>((ref) => null);

final homeViewProvider = StateProvider<HomeView>((ref) => HomeView.list);

final activeTabProvider = StateProvider<AppTab>((ref) => AppTab.home);

/// Month offset for the timeline stepper, relative to the current month.
final timelineMonthOffsetProvider = StateProvider<int>((ref) => 0);
