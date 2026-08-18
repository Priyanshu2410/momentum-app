import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/enums/repeat_type.dart';
import '../../../domain/enums/task_label.dart';
import '../../../domain/enums/task_priority.dart';
import '../../../domain/enums/task_status.dart';
import '../../actions/task_actions.dart';
import '../../providers/app_providers.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/ui_feedback_provider.dart';
import '../../widgets/filter_pill.dart';
import '../../widgets/when_picker.dart';
import '../repeat/repeat_screen.dart';
import 'widgets/field_row.dart';

/// Opens the detail sheet for [taskId]. No-op if the task is already gone.
Future<void> showTaskDetailSheet(
  BuildContext context,
  WidgetRef ref,
  int taskId,
) async {
  if (ref.read(sheetOpenProvider)) return;
  final task = await ref.read(taskRepositoryProvider).findTask(taskId);
  if (task == null || !context.mounted) return;

  ref.read(sheetOpenProvider.notifier).state = true;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TaskDetailSheet(taskId: taskId),
  );
  ref.read(sheetOpenProvider.notifier).state = false;
}

class TaskDetailSheet extends ConsumerStatefulWidget {
  const TaskDetailSheet({required this.taskId, super.key});

  final int taskId;

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();

  late DateTime _start;
  DateTime? _due;
  late TaskPriority _priority;
  late TaskLabel _label;
  late RepeatType _repeatType;
  Map<String, dynamic>? _repeatConfig;

  String? _error;
  bool _seeded = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  /// Seeds the editable copy once, so live stream updates never stomp on what
  /// is being typed.
  void _seed(Task task) {
    if (_seeded) return;
    _seeded = true;
    _title.text = task.title;
    _description.text = task.description ?? '';
    _start = task.startDateTime;
    _due = task.dueDateTime;
    _priority = task.priority;
    _label = task.label;
    _repeatType = task.repeatType;
    _repeatConfig = task.repeatConfig;
  }

  @override
  Widget build(BuildContext context) {
    final task = ref.watch(taskByIdProvider(widget.taskId));
    if (task == null) return const SizedBox.shrink();
    _seed(task);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppRadius.sheet,
      ),
      child: Column(
        children: [
          const _DragHandle(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, 12, AppSpacing.xl, AppSpacing.xl),
              children: [
                _StatusSelector(task: task),
                const SizedBox(height: 20),
                TextField(
                  controller: _title,
                  style: AppTypography.sheetTitle,
                  maxLines: null,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _description,
                  style: AppTypography.body,
                  maxLines: null,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: AppStrings.addDescription,
                    hintStyle: AppTypography.body,
                  ),
                ),
                const SizedBox(height: 20),
                const _Divider(),
                FieldRow(
                  icon: AppIcons.clock,
                  name: 'Starts',
                  value: AppDates.whenLabel(_start, DateTime.now()),
                  hint: AppDates.full(_start),
                  valueColor: AppColors.accent,
                  onTap: _pickStart,
                ),
                FieldRow(
                  icon: AppIcons.calendar,
                  name: 'Due by',
                  value: _due == null
                      ? AppStrings.noDueDate
                      : AppDates.whenLabel(_due!, DateTime.now()),
                  hint: _due == null ? null : AppDates.full(_due!),
                  valueColor: _due == null
                      ? AppColors.textMuted
                      : AppColors.statusOverdue,
                  onTap: _pickDue,
                ),
                FieldRow(
                  icon: AppIcons.flag,
                  name: 'Priority',
                  value: _priority.label,
                  valueColor: _priority.color,
                  onTap: _pickPriority,
                ),
                FieldRow(
                  icon: AppIcons.tag,
                  name: 'Label',
                  value: _label.label,
                  valueColor: _label.color,
                  onTap: _pickLabel,
                ),
                FieldRow(
                  icon: AppIcons.repeat,
                  name: 'Repeat',
                  value: _repeatLabel,
                  onTap: _pickRepeat,
                ),
                const _Divider(),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      style: AppTypography.fieldValue
                          .copyWith(color: AppColors.statusOverdue),
                    ),
                  ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await ref.deleteTask(task);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      AppStrings.deleteTask,
                      textAlign: TextAlign.center,
                      style: AppTypography.fieldLabel
                          .copyWith(color: AppColors.statusOverdue),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              MediaQuery.viewInsetsOf(context).bottom + 30,
            ),
            child: _PrimaryButton(
              label: AppStrings.saveChanges,
              onTap: () => _save(task),
            ),
          ),
        ],
      ),
    );
  }

  String get _repeatLabel {
    if (_repeatType == RepeatType.custom) {
      final n = _repeatConfig?['interval'] ?? 1;
      final unit = _repeatConfig?['unit'] ?? 'weeks';
      return 'Every $n $unit';
    }
    return _repeatType.label;
  }

  Future<void> _pickStart() async {
    final picked = await showWhenPicker(
      context,
      title: AppStrings.whenStart,
      initial: _start,
    );
    if (picked?.value != null) setState(() => _start = picked!.value!);
  }

  /// Anchored to the start time, so every preset is a duration *after* the task
  /// begins — the old picker happily offered a due date before the start.
  Future<void> _pickDue() async {
    final picked = await showWhenPicker(
      context,
      title: AppStrings.whenDue,
      initial: _due ?? _start.add(const Duration(hours: 1)),
      anchor: _start,
      allowNone: true,
    );
    if (picked != null) setState(() => _due = picked.value);
  }

  Future<void> _pickPriority() async {
    final picked = await showOptionPicker<TaskPriority>(
      context,
      title: 'Priority',
      options: TaskPriority.values,
      labelOf: (p) => p.label,
      colorOf: (p) => p.color,
      selected: _priority,
    );
    if (picked != null) setState(() => _priority = picked);
  }

  Future<void> _pickLabel() async {
    final picked = await showOptionPicker<TaskLabel>(
      context,
      title: 'Label',
      options: TaskLabel.values,
      labelOf: (l) => l.label,
      colorOf: (l) => l.color,
      selected: _label,
    );
    if (picked != null) setState(() => _label = picked);
  }

  Future<void> _pickRepeat() async {
    final picked = await showRepeatPicker(
      context,
      type: _repeatType,
      config: _repeatConfig,
    );
    if (picked != null) {
      setState(() {
        _repeatType = picked.type;
        _repeatConfig = picked.config;
      });
    }
  }

  Future<void> _save(Task task) async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = AppStrings.titleRequired);
      return;
    }
    if (_due != null && !_due!.isAfter(_start)) {
      setState(() => _error = AppStrings.startBeforeDue);
      return;
    }

    final description = _description.text.trim();
    await ref.read(taskRepositoryProvider).updateTask(
          task.copyWith(
            title: title,
            description: description.isEmpty ? null : description,
            startDateTime: _start,
            dueDateTime: _due,
            priority: _priority,
            label: _label,
            repeatType: _repeatType,
            repeatConfig: _repeatConfig,
          ),
        );

    if (!mounted) return;
    Navigator.of(context).pop();
    ref.read(toastProvider.notifier).show(
          AppStrings.taskUpdated,
          duration: const Duration(seconds: 2),
        );
  }
}

/// Live status pills — tapping one commits immediately, as in the design.
class _StatusSelector extends ConsumerWidget {
  const _StatusSelector({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A Wrap, not a horizontal list: the list put "Done" off the right edge, so
    // changing a task to Done meant finding a sideways scroll inside a sheet
    // that already scrolls vertically. Every status is now visible and one tap
    // away, which beats a dropdown for the same job.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final status in TaskStatus.values)
          FilterPill(
            label: status.label,
            active: task.status == status,
            accent: status.color,
            dotColor: status.color,
            height: 30,
            onTap: () => ref.setTaskStatus(task, status),
          ),
      ],
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
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
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: ColoredBox(
          color: AppColors.border,
          child: SizedBox(height: 1, width: double.infinity),
        ),
      );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          borderRadius: AppRadius.control,
        ),
        child: Text(label, style: AppTypography.button),
      ),
    );
  }
}
