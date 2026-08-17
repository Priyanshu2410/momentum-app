import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// "icon — name — value" row used down the detail sheet. An optional [hint]
/// sits under the value: the friendly wording goes on top, the exact
/// timestamp underneath, so neither has to be guessed at.
class FieldRow extends StatelessWidget {
  const FieldRow({
    required this.icon,
    required this.name,
    required this.value,
    required this.onTap,
    this.valueColor = AppColors.textSecondary,
    this.hint,
    super.key,
  });

  final IconData icon;
  final String name;
  final String value;
  final Color valueColor;
  final String? hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: hint == null ? 48 : 58,
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 12),
            SizedBox(width: 74, child: Text(name, style: AppTypography.fieldLabel)),
            const Spacer(),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.fieldValue.copyWith(color: valueColor),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      hint!,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.meta.copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small option list in a bottom sheet. Returns null when dismissed.
Future<T?> showOptionPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  required Color Function(T) colorOf,
  required T selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.surface1,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
    useSafeArea: true,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
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
            const SizedBox(height: 16),
            for (final option in options)
              GestureDetector(
                onTap: () => Navigator.of(sheetContext).pop(option),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: option == selected
                        ? colorOf(option).withValues(alpha: 0.12)
                        : AppColors.surface2,
                    borderRadius: AppRadius.control,
                    border: Border.all(
                      color: option == selected
                          ? colorOf(option).withValues(alpha: 0.45)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorOf(option),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        labelOf(option),
                        style: AppTypography.fieldLabel.copyWith(
                          fontWeight: FontWeight.w500,
                          color: option == selected
                              ? colorOf(option)
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
