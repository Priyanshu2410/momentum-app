import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/app_providers.dart';
import '../../providers/board_filter_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/ui_feedback_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_header.dart';
import '../../widgets/momentum_logo.dart';
import '../../widgets/momentum_toast.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../quick_add/quick_add_sheet.dart';
import '../settings/settings_sheet.dart';
import '../task_detail/task_detail_sheet.dart';
import '../timeline/timeline_screen.dart';
import '../update/update_sheet.dart';

/// Header, tab body, floating nav and FAB. Also the place where the scheduler
/// runs on start and on resume.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref
        .read(notificationServiceProvider)
        .tappedTaskId
        .addListener(_onNotificationTapped);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runScheduler();
      _checkForUpdate();
      // A cold start from a notification tap seeds this before the first build.
      final pending = ref.read(pendingTaskIdProvider);
      if (pending != null) _openPendingTask(pending);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref
        .read(notificationServiceProvider)
        .tappedTaskId
        .removeListener(_onNotificationTapped);
    super.dispose();
  }

  /// Opening the app is the other half of the promotion story — workmanager
  /// only runs every 15 minutes, and not at all on iOS.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _runScheduler();
  }

  void _onNotificationTapped() {
    final id = ref.read(notificationServiceProvider).tappedTaskId.value;
    if (id != null) ref.read(pendingTaskIdProvider.notifier).state = id;
  }

  Future<void> _runScheduler() async {
    final result = await ref
        .read(taskSchedulerProvider)
        .sync(settings: ref.read(settingsProvider));
    if (!mounted || result.promoted.isEmpty) return;

    ref.read(pulseProvider.notifier).pulse(result.promoted.map((t) => t.id));
    ref
        .read(toastProvider.notifier)
        .show(AppStrings.startedToast(result.promoted.first.title));
  }

  /// Throttled to once a day inside the service, and silent unless there is
  /// actually a newer release. A notification tap wins: if that already opened
  /// a sheet, the update can wait for the next start.
  Future<void> _checkForUpdate() async {
    final update = await ref.read(updateServiceProvider).checkOnLaunch();
    if (update == null || !mounted || ref.read(sheetOpenProvider)) return;
    await showUpdateSheet(context, ref, update);
  }

  void _openPendingTask(int id) {
    ref.read(pendingTaskIdProvider.notifier).state = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showTaskDetailSheet(context, ref, id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // A notification tapped while the app is running lands here.
    ref.listen<int?>(pendingTaskIdProvider, (_, next) {
      if (next != null) _openPendingTask(next);
    });

    final tab = ref.watch(activeTabProvider);
    final topInset = math.max(MediaQuery.paddingOf(context).top, 44.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: topInset),
              const MomentumLogo(),
              const SizedBox(height: 10),
              AppHeader(onSettings: () => showSettingsSheet(context, ref)),
              Expanded(
                child: IndexedStack(
                  index: tab.index,
                  children: const [
                    HomeScreen(),
                    TimelineScreen(),
                    NotificationsScreen(),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: AppBottomNav()),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.fabBottom,
            child: Center(
              child: MomentumFab(onTap: () => showQuickAddSheet(context, ref)),
            ),
          ),
          const MomentumToast(),
        ],
      ),
    );
  }
}
