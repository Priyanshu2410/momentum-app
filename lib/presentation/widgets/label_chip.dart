import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../domain/enums/task_label.dart';

/// 21px tinted pill carrying the task's label.
class LabelChip extends StatelessWidget {
  const LabelChip(this.label, {super.key});

  final TaskLabel label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 21,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: label.tint,
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label.label,
        style: AppTypography.chip.copyWith(color: label.color),
      ),
    );
  }
}
