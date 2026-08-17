import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/date_utils.dart';
import '../actions/task_actions.dart';

/// What the picker came back with. A null [value] on a returned choice means
/// "clear it" — which is a different answer from dismissing the sheet, and the
/// reason this is not just a `DateTime?`.
class WhenChoice {
  const WhenChoice(this.value);
  const WhenChoice.cleared() : value = null;

  final DateTime? value;
}

/// One sheet for every "when does this happen" question in the app.
///
/// Presets carry their resolved date on the right, so the answer is visible
/// before the tap — that is the whole point of it. The two-picker date/time
/// dance is still there under "Pick exact date & time" for the rare case.
///
/// [anchor] switches it to due-date mode: presets are measured from the start
/// time, so due can never be set before the task begins.
Future<WhenChoice?> showWhenPicker(
  BuildContext context, {
  required String title,
  required DateTime initial,
  DateTime? anchor,
  bool allowNone = false,
}) {
  final now = DateTime.now();
  final presets =
      anchor == null ? AppDates.startPresets(now) : AppDates.duePresets(anchor);

  return showModalBottomSheet<WhenChoice>(
    context: context,
    backgroundColor: AppColors.surface1,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.surface3,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: AppTypography.fieldLabel
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.whenCurrent(AppDates.whenLabel(initial, now)),
                style: AppTypography.meta,
              ),
              const SizedBox(height: 16),
              for (final (label, value) in presets)
                _WhenRow(
                  label: label,
                  detail: '${AppDates.day(value)} · ${AppDates.time(value)}',
                  selected: value.difference(initial).inMinutes.abs() < 1,
                  onTap: () =>
                      Navigator.of(sheetContext).pop(WhenChoice(value)),
                ),
              _WhenRow(
                label: 'Pick exact date & time',
                detail: '',
                icon: AppIcons.calendar,
                onTap: () async {
                  final picked = await pickDateTime(sheetContext, initial);
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext)
                      .pop(picked == null ? null : WhenChoice(picked));
                },
              ),
              if (allowNone)
                _WhenRow(
                  label: 'No due date',
                  detail: '',
                  muted: true,
                  onTap: () => Navigator.of(sheetContext)
                      .pop(const WhenChoice.cleared()),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _WhenRow extends StatelessWidget {
  const _WhenRow({
    required this.label,
    required this.detail,
    required this.onTap,
    this.icon,
    this.selected = false,
    this.muted = false,
  });

  final String label;
  final String detail;
  final VoidCallback onTap;
  final IconData? icon;
  final bool selected;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppColors.accent : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentTint : AppColors.surface2,
          borderRadius: AppRadius.control,
          border: Border.all(
            color: selected ? AppColors.accentEdge : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                style: AppTypography.fieldLabel.copyWith(
                  fontWeight: FontWeight.w500,
                  color: muted ? AppColors.textMuted : accent,
                ),
              ),
            ),
            Text(detail, style: AppTypography.meta),
          ],
        ),
      ),
    );
  }
}
