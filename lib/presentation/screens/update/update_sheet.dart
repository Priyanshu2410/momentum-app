import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/update_service.dart';
import '../../providers/ui_feedback_provider.dart';
import '../../widgets/momentum_logo.dart';

/// Offers the new build. Tapping through opens the APK link in the browser —
/// Android's own installer takes it from there, which is the only way to update
/// a sideloaded app without shipping an installer permission.
Future<void> showUpdateSheet(
  BuildContext context,
  WidgetRef ref,
  AppUpdate update,
) async {
  if (ref.read(sheetOpenProvider)) return;
  ref.read(sheetOpenProvider.notifier).state = true;
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _UpdateSheet(update: update),
  );
  ref.read(sheetOpenProvider.notifier).state = false;
}

class _UpdateSheet extends StatefulWidget {
  const _UpdateSheet({required this.update});

  final AppUpdate update;

  @override
  State<_UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<_UpdateSheet> {
  /// Set when the browser could not be opened. Shown inline rather than as a
  /// toast: this sheet is a modal route above the shell, so a toast painted by
  /// the shell would sit behind it and never be seen.
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    final update = widget.update;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppRadius.sheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                AppSpacing.xl, 14, AppSpacing.xl, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const MomentumMark(size: 34),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.updateTitle,
                            style: AppTypography.fieldLabel.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            AppStrings.updateVersions(
                              UpdateService.currentVersion,
                              update.version,
                            ),
                            style: AppTypography.meta,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (update.notes.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: SingleChildScrollView(
                      child: Text(update.notes, style: AppTypography.body),
                    ),
                  ),
                ],
                if (_failed) ...[
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.updateOpenFailed,
                    style: AppTypography.fieldValue
                        .copyWith(color: AppColors.statusOverdue),
                  ),
                  const SizedBox(height: 6),
                  // The link itself, so it is still reachable by hand.
                  SelectableText(
                    update.downloadUrl,
                    style: AppTypography.meta,
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _download,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: AppRadius.control,
                          ),
                          child: const Text(AppStrings.updateDownload,
                              style: AppTypography.button),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.control,
                          border: Border.all(color: AppColors.borderStrong),
                        ),
                        child: Text(
                          AppStrings.updateLater,
                          style: AppTypography.fieldValue
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _download() async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(widget.update.downloadUrl),
        mode: LaunchMode.externalApplication,
      );
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[update] launch failed: $e');
    }

    if (!mounted) return;
    if (opened) {
      Navigator.of(context).pop();
      return;
    }
    // Failing silently here is what made a missing manifest query look like a
    // dead button.
    setState(() => _failed = true);
  }
}
