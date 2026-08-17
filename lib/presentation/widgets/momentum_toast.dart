import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../providers/ui_feedback_provider.dart';

/// The design's floating notice, pinned below the status bar. Drops in from
/// above and clears itself via [toastProvider].
class MomentumToast extends ConsumerWidget {
  const MomentumToast({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(toastProvider);
    if (message == null) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.paddingOf(context).top,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () => ref.read(toastProvider.notifier).dismiss(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: AppRadius.control,
            border: Border.all(color: AppColors.borderStrong),
            boxShadow: const [
              BoxShadow(
                color: Color(0x8C000000),
                blurRadius: 30,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(message, style: AppTypography.notification),
              ),
            ],
          ),
        ),
      )
          .animate()
          .slideY(begin: -1.4, end: 0, duration: 320.ms, curve: Curves.easeOutBack)
          .fadeIn(duration: 200.ms),
    );
  }
}
