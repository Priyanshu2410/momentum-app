import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../domain/enums/task_label.dart';
import '../../../providers/board_filter_provider.dart';
import '../../../widgets/filter_pill.dart';

/// Scrolling label pills plus the list/board toggle.
class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  /// The design's pill row stops at Finance; "Other" tasks show under All.
  static const _labels = [
    TaskLabel.work,
    TaskLabel.personal,
    TaskLabel.health,
    TaskLabel.finance,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(labelFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 18, AppSpacing.xl, AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 29,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FilterPill(
                    label: 'All',
                    active: active == null,
                    onTap: () =>
                        ref.read(labelFilterProvider.notifier).state = null,
                  ),
                  for (final label in _labels) ...[
                    const SizedBox(width: 6),
                    FilterPill(
                      label: label.label,
                      active: active == label,
                      onTap: () =>
                          ref.read(labelFilterProvider.notifier).state = label,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const _ViewToggle(),
        ],
      ),
    );
  }
}

class _ViewToggle extends ConsumerWidget {
  const _ViewToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(homeViewProvider);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppRadius.pill,
        border: Border.all(color: const Color(0x12FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: AppIcons.listView,
            active: view == HomeView.list,
            onTap: () =>
                ref.read(homeViewProvider.notifier).state = HomeView.list,
          ),
          _ToggleButton(
            icon: AppIcons.boardView,
            active: view == HomeView.board,
            onTap: () =>
                ref.read(homeViewProvider.notifier).state = HomeView.board,
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 30,
        height: 24,
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : Colors.transparent,
          borderRadius: AppRadius.pill,
        ),
        child: Icon(
          icon,
          size: 15,
          color: active ? AppColors.accent : AppColors.textMuted,
        ),
      ),
    );
  }
}
