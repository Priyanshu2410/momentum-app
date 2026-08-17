import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/enums/repeat_type.dart';

/// What the repeat picker hands back.
class RepeatSelection {
  const RepeatSelection(this.type, this.config);

  final RepeatType type;
  final Map<String, dynamic>? config;
}

/// Full-screen repeat picker. Weekly reveals a day selector, Custom reveals an
/// interval + unit row.
Future<RepeatSelection?> showRepeatPicker(
  BuildContext context, {
  required RepeatType type,
  required Map<String, dynamic>? config,
}) {
  return Navigator.of(context).push<RepeatSelection>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => RepeatScreen(initialType: type, initialConfig: config),
    ),
  );
}

class RepeatScreen extends StatefulWidget {
  const RepeatScreen({
    required this.initialType,
    required this.initialConfig,
    super.key,
  });

  final RepeatType initialType;
  final Map<String, dynamic>? initialConfig;

  @override
  State<RepeatScreen> createState() => _RepeatScreenState();
}

class _RepeatScreenState extends State<RepeatScreen> {
  static const _weekdayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _units = ['days', 'weeks', 'months'];

  late RepeatType _type = widget.initialType;
  late final Set<int> _days = _readDays(widget.initialConfig);
  late int _every = (widget.initialConfig?['interval'] as num?)?.toInt() ?? 2;
  late String _unit = widget.initialConfig?['unit'] as String? ?? 'weeks';

  static Set<int> _readDays(Map<String, dynamic>? config) {
    final raw = config?['days'];
    if (raw is List) return raw.whereType<num>().map((n) => n.toInt()).toSet();
    // Default to the design's Mon/Wed selection.
    return {1, 3};
  }

  Map<String, dynamic>? get _config => switch (_type) {
        RepeatType.weekly =>
          _days.isEmpty ? null : {'days': _days.toList()..sort()},
        RepeatType.custom => {'interval': _every, 'unit': _unit},
        _ => null,
      };

  void _close() =>
      Navigator.of(context).pop(RepeatSelection(_type, _config));

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back gesture keeps the selection rather than discarding it.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                MediaQuery.paddingOf(context).top + 12,
                AppSpacing.xl,
                20,
              ),
              child: Row(
                children: [
                  const Text('Repeat', style: AppTypography.screenTitle),
                  const Spacer(),
                  GestureDetector(
                    onTap: _close,
                    behavior: HitTestBehavior.opaque,
                    child: const Icon(AppIcons.close,
                        size: 22, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 0, AppSpacing.xl, 40),
                children: [
                  for (final option in RepeatType.values) ...[
                    _OptionRow(
                      label: option.label,
                      hint: option.hint,
                      active: _type == option,
                      onTap: () => setState(() => _type = option),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_type == RepeatType.weekly) _buildWeekly(),
                  if (_type == RepeatType.custom) _buildCustom(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekly() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DAYS', style: AppTypography.sectionHeader),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                Expanded(
                  child: _DayToggle(
                    letter: _weekdayLetters[i],
                    active: _days.contains(i),
                    onTap: () => setState(() {
                      if (!_days.remove(i)) _days.add(i);
                    }),
                  ),
                ),
                if (i < 6) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustom() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const Text('Every', style: AppTypography.fieldLabel),
          const SizedBox(width: 10),
          GestureDetector(
            // Tap cycles 1..9, matching the design's bump control.
            onTap: () => setState(() => _every = _every >= 9 ? 1 : _every + 1),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 44,
              constraints: const BoxConstraints(minWidth: 56),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: AppRadius.notification,
                border: Border.all(color: AppColors.border),
              ),
              child: Text('$_every',
                  style: AppTypography.fieldLabel
                      .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            ),
          ),
          for (final unit in _units) ...[
            const SizedBox(width: 10),
            _UnitChip(
              label: unit,
              active: _unit == unit,
              onTap: () => setState(() => _unit = unit),
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.hint,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String hint;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.accentTint : AppColors.surface1,
          borderRadius: AppRadius.control,
          border: Border.all(
              color: active ? AppColors.accentEdge : AppColors.border),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.fieldLabel.copyWith(
                fontWeight: FontWeight.w500,
                color: active ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(hint, style: AppTypography.meta),
          ],
        ),
      ),
    );
  }
}

class _DayToggle extends StatelessWidget {
  const _DayToggle({
    required this.letter,
    required this.active,
    required this.onTap,
  });

  final String letter;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.surface1,
          borderRadius: AppRadius.pill,
          border:
              Border.all(color: active ? AppColors.accent : AppColors.border),
        ),
        child: Text(
          letter,
          style: AppTypography.fieldValue.copyWith(
            color: active ? AppColors.onAccent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.accentTint : AppColors.surface1,
          borderRadius: AppRadius.notification,
          border: Border.all(
              color: active ? AppColors.accentEdge : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.fieldValue.copyWith(
            color: active ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
