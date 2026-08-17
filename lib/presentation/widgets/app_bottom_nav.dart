import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_spacing.dart';
import '../providers/app_providers.dart';
import '../providers/board_filter_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/ui_feedback_provider.dart';

/// Blurred bar pinned to the bottom. The FAB is a separate sibling floating
/// above it — the design does not notch it into the bar.
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(activeTabProvider);
    final hasUnread = ref.watch(hasUnreadProvider);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: AppSpacing.navHeight,
          padding: const EdgeInsets.only(top: 14),
          decoration: const BoxDecoration(
            color: Color(0xEB0A0A0C), // rgba(10,10,12,0.92)
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NavItem(
                icon: AppIcons.home,
                active: tab == AppTab.home,
                onTap: () => ref.read(activeTabProvider.notifier).state = AppTab.home,
              ),
              _NavItem(
                icon: AppIcons.timeline,
                active: tab == AppTab.timeline,
                onTap: () =>
                    ref.read(activeTabProvider.notifier).state = AppTab.timeline,
              ),
              _NavItem(
                icon: tab == AppTab.notifications
                    ? AppIcons.bellFilled
                    : AppIcons.bell,
                active: tab == AppTab.notifications,
                badge: hasUnread,
                onTap: () {
                  ref.read(activeTabProvider.notifier).state =
                      AppTab.notifications;
                  // Opening the tab is the read receipt.
                  ref.read(taskRepositoryProvider).markAllNotificationsRead();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accent : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(icon, size: 22, color: color),
                ),
                if (badge)
                  const Positioned(
                    top: -1,
                    right: -2,
                    child: SizedBox(
                      width: 6,
                      height: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.statusOverdue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: active ? AppColors.accent : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating teal action button. Its plus rotates to a cross while a sheet is up.
class MomentumFab extends ConsumerWidget {
  const MomentumFab({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(sheetOpenProvider);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedRotation(
        turns: open ? 0.125 : 0, // 45°
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: Container(
          width: AppSpacing.fabSize,
          height: AppSpacing.fabSize,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x473FD6B4),
                blurRadius: 26,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(AppIcons.plus, size: 24, color: AppColors.onAccent),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
              duration: 3600.ms,
              color: const Color(0x73FFFFFF),
            ),
      ),
    );
  }
}
