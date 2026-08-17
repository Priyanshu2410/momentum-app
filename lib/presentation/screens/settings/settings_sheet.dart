import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/update_service.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../providers/ui_feedback_provider.dart';
import '../update/update_sheet.dart';

Future<void> showSettingsSheet(BuildContext context, WidgetRef ref) async {
  if (ref.read(sheetOpenProvider)) return;
  ref.read(sheetOpenProvider.notifier).state = true;
  // The update row pops this sheet with what it found: the update sheet cannot
  // open until `sheetOpenProvider` is back to false, which happens below.
  final update = await showModalBottomSheet<AppUpdate>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const SettingsSheet(),
  );
  ref.read(sheetOpenProvider.notifier).state = false;

  if (update != null && context.mounted) {
    await showUpdateSheet(context, ref, update);
  }
}

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppRadius.sheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, 8, AppSpacing.xl, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.settings,
                  style: AppTypography.fieldLabel
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                _ToggleRow(
                  label: AppStrings.autoPromote,
                  value: settings.autoPromote,
                  onChanged: notifier.setAutoPromote,
                ),
                _ToggleRow(
                  label: AppStrings.pushNotifications,
                  value: settings.pushEnabled,
                  onChanged: notifier.setPushEnabled,
                ),
                const _UpdateRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Manual counterpart to the once-a-day check on app start. Says something
/// either way — a check that silently does nothing reads as broken.
class _UpdateRow extends ConsumerStatefulWidget {
  const _UpdateRow();

  @override
  ConsumerState<_UpdateRow> createState() => _UpdateRowState();
}

class _UpdateRowState extends ConsumerState<_UpdateRow> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final service = ref.read(updateServiceProvider);

    return GestureDetector(
      onTap: _busy || !service.enabled ? null : _check,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.checkForUpdates,
                style: AppTypography.fieldLabel.copyWith(
                  color: service.enabled
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _busy
                  ? AppStrings.checking
                  : service.enabled
                      ? UpdateService.currentVersion
                      : AppStrings.updatesUnavailable,
              style: AppTypography.meta,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _check() async {
    setState(() => _busy = true);
    final update = await ref.read(updateServiceProvider).check();
    if (!mounted) return;
    setState(() => _busy = false);

    if (update == null) {
      ref.read(toastProvider.notifier).show(AppStrings.upToDate);
      return;
    }
    Navigator.of(context).pop(update);
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.fieldLabel
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 46,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? AppColors.accent : AppColors.surface3,
                borderRadius: AppRadius.pill,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: value ? AppColors.onAccent : AppColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
