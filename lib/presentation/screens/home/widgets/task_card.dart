import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/task.dart';
import '../../../../domain/enums/task_status.dart';
import '../../../widgets/accent_edge_card.dart';
import '../../../widgets/label_chip.dart';
import '../../../widgets/priority_dot.dart';

/// Reveal widths from the design: two 66px actions behind the card.
const double _actionWidth = 66;
const double _revealExtent = _actionWidth * 2;
const double _completeExtent = 120;

/// Swipeable list card. Left drag reveals Snooze + Delete, right drag past the
/// threshold completes the task.
class TaskCard extends StatefulWidget {
  const TaskCard({
    required this.task,
    required this.index,
    required this.pulsing,
    required this.onOpen,
    required this.onComplete,
    required this.onSnooze,
    required this.onDelete,
    super.key,
  });

  final Task task;
  final int index;

  /// True for the ~1.4s after the task auto-promoted.
  final bool pulsing;

  final VoidCallback onOpen;
  final VoidCallback onComplete;
  final VoidCallback onSnooze;
  final VoidCallback onDelete;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  double _dx = 0;
  bool _dragging = false;

  void _onUpdate(DragUpdateDetails d) {
    setState(() {
      _dragging = true;
      _dx = (_dx + d.delta.dx).clamp(-_revealExtent, _completeExtent);
    });
  }

  void _onEnd(DragEndDetails _) {
    setState(() => _dragging = false);
    if (_dx < -_actionWidth) {
      setState(() => _dx = -_revealExtent); // hold the actions open
    } else if (_dx > 76 && !widget.task.isDone) {
      setState(() => _dx = 0);
      widget.onComplete();
    } else {
      setState(() => _dx = 0);
    }
  }

  void _close() => setState(() => _dx = 0);

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned.fill(child: _ActionLayer(onSnooze: _snooze, onDelete: _delete)),
          GestureDetector(
            onHorizontalDragUpdate: _onUpdate,
            onHorizontalDragEnd: _onEnd,
            onTap: () {
              // A revealed card taps closed rather than opening the sheet.
              if (_dx != 0) {
                _close();
              } else {
                widget.onOpen();
              }
            },
            child: AnimatedContainer(
              duration: _dragging ? Duration.zero : const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              transform: Matrix4.translationValues(_dx, 0, 0),
              child: AccentEdgeCard(
                accent: task.status.color,
                background: task.status == TaskStatus.overdue
                    ? AppColors.overdueCard
                    : AppColors.surface1,
                padding: AppSpacing.cardPadding,
                boxShadow: widget.pulsing
                    ? const [
                        BoxShadow(
                          color: Color(0x8C000000),
                          blurRadius: 30,
                          offset: Offset(0, 10),
                        ),
                      ]
                    : null,
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StrikeableTitle(
                          text: task.title,
                          struck: task.isDone,
                          style: AppTypography.cardTitle.copyWith(
                            color: task.isDone
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 11),
                        TaskMetaRow(task: task),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: PriorityDot(
                      priority: task.priority,
                      status: task.status,
                      pulsing: widget.pulsing,
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 440.ms, delay: (widget.index * 45).ms)
        .moveY(begin: 10, end: 0, duration: 440.ms, curve: Curves.easeOutCubic);
  }

  void _snooze() {
    _close();
    widget.onSnooze();
  }

  void _delete() {
    _close();
    widget.onDelete();
  }
}

/// What sits behind the card: the completion wash on the left, the two
/// actions on the right.
class _ActionLayer extends StatelessWidget {
  const _ActionLayer({required this.onSnooze, required this.onDelete});

  final VoidCallback onSnooze;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.card,
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: const Color(0x293FD6B4), // rgba(63,214,180,0.16)
              padding: const EdgeInsets.only(left: 18),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.check, size: 16, color: AppColors.accent),
                  const SizedBox(width: 7),
                  Text('Done',
                      style: AppTypography.pill.copyWith(color: AppColors.accent)),
                ],
              ),
            ),
          ),
          _Action(
            icon: AppIcons.snooze,
            label: 'Snooze',
            background: AppColors.surface3,
            foreground: AppColors.textSecondary,
            onTap: onSnooze,
          ),
          _Action(
            icon: AppIcons.delete,
            label: 'Delete',
            background: AppColors.statusOverdue,
            foreground: AppColors.background,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _actionWidth,
        color: background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: foreground),
            const SizedBox(height: 5),
            Text(label, style: AppTypography.chip.copyWith(color: foreground)),
          ],
        ),
      ),
    );
  }
}

/// Title that hugs its own text width, so the strike-through animates across
/// the words rather than the whole card.
class StrikeableTitle extends StatelessWidget {
  const StrikeableTitle({
    required this.text,
    required this.struck,
    required this.style,
    super.key,
  });

  final String text;
  final bool struck;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1, // sizes to the text, like display:inline-block
      child: Stack(
        children: [
          Text(text, style: style),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: struck ? 1 : 0),
                duration: const Duration(milliseconds: 250),
                builder: (context, value, _) => FractionallySizedBox(
                  widthFactor: value,
                  child: ColoredBox(
                    color: style.color ?? AppColors.textSecondary,
                    child: const SizedBox(height: 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label chip, time, day and the recurring glyph.
class TaskMetaRow extends StatelessWidget {
  const TaskMetaRow({required this.task, super.key});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LabelChip(task.label),
        const SizedBox(width: 10),
        Icon(
          AppIcons.clock,
          size: 13,
          color: task.isDone ? AppColors.textMuted : AppColors.accent,
        ),
        const SizedBox(width: 5),
        Text(
          AppDates.time(task.startDateTime),
          style: AppTypography.cardMeta.copyWith(
            color: task.isDone ? AppColors.textMuted : AppColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            AppDates.day(task.startDateTime),
            style: AppTypography.meta,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (task.repeats) ...[
          const SizedBox(width: 8),
          const Icon(AppIcons.repeat, size: 13, color: AppColors.textMuted),
        ],
      ],
    );
  }
}

/// Non-swipeable card for the board columns and the timeline.
class CompactTaskCard extends StatelessWidget {
  const CompactTaskCard({
    required this.task,
    required this.index,
    required this.onOpen,
    this.pulsing = false,
    this.faded = false,
    this.highlightToday = false,
    super.key,
  });

  final Task task;
  final int index;
  final VoidCallback onOpen;
  final bool pulsing;

  /// Past timeline entries sit back at 55%.
  final bool faded;

  /// Today's timeline entries get a faint teal rim.
  final bool highlightToday;

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: AccentEdgeCard(
        accent: task.status.color,
        background: task.status == TaskStatus.overdue
            ? AppColors.overdueCard
            : AppColors.surface1,
        padding: AppSpacing.cardPaddingCompact,
        boxShadow: highlightToday
            ? const [BoxShadow(color: Color(0x1A3FD6B4), blurRadius: 0, spreadRadius: 1)]
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LabelChip(task.label),
                const Spacer(),
                PriorityDot(
                  priority: task.priority,
                  status: task.status,
                  pulsing: pulsing,
                ),
              ],
            ),
            const SizedBox(height: 10),
            StrikeableTitle(
              text: task.title,
              struck: task.isDone,
              style: AppTypography.cardTitleCompact.copyWith(
                color: task.isDone
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                Icon(
                  AppIcons.clock,
                  size: 13,
                  color: task.isDone ? AppColors.textMuted : AppColors.accent,
                ),
                const SizedBox(width: 5),
                Text(
                  AppDates.time(task.startDateTime),
                  style: AppTypography.cardMeta.copyWith(
                    color: task.isDone ? AppColors.textMuted : AppColors.accent,
                  ),
                ),
                const SizedBox(width: 11),
                Flexible(
                  child: Text(
                    AppDates.day(task.startDateTime),
                    style: AppTypography.meta,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return RepaintBoundary(
      child: Opacity(opacity: faded ? 0.55 : 1, child: card),
    )
        .animate()
        .fadeIn(duration: 440.ms, delay: (index * 45).ms)
        .moveY(begin: 10, end: 0, duration: 440.ms, curve: Curves.easeOutCubic);
  }
}
