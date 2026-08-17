import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/enums/task_label.dart';
import '../../../domain/enums/task_priority.dart';
import '../../providers/app_providers.dart';
import '../../providers/board_filter_provider.dart';
import '../../providers/ui_feedback_provider.dart';
import '../../widgets/when_picker.dart';
import '../task_detail/widgets/field_row.dart';

Future<void> showQuickAddSheet(BuildContext context, WidgetRef ref) async {
  if (ref.read(sheetOpenProvider)) return;
  ref.read(sheetOpenProvider.notifier).state = true;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const QuickAddSheet(),
  );
  ref.read(sheetOpenProvider.notifier).state = false;
}

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();

  /// Defaults to now: adding a task means you are doing it, so it lands in
  /// In Progress. Pushing the start into the future is what makes it Scheduled.
  late DateTime _start = DateTime.now();
  TaskPriority _priority = TaskPriority.medium;
  TaskLabel _label = TaskLabel.personal;

  String? _error;

  bool get _startsNow => !_start.isAfter(DateTime.now());

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lifts the whole sheet clear of the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: AppRadius.sheet,
        ),
        child: SingleChildScrollView(
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
                    AppSpacing.xl, 6, AppSpacing.xl, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.newTask,
                      style: AppTypography.fieldLabel.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _title,
                      autofocus: true,
                      style: AppTypography.input,
                      textInputAction: TextInputAction.next,
                      maxLines: null,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: AppStrings.titleHint,
                        hintStyle: AppTypography.input,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _description,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: AppStrings.descriptionHint,
                        hintStyle: AppTypography.body,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(
                          label: AppDates.whenLabel(_start, DateTime.now()),
                          active: true,
                          accent: _startsNow
                              ? AppColors.statusInProgress
                              : AppColors.statusScheduled,
                          onTap: _pickWhen,
                        ),
                        _Chip(
                          label: _priority.label,
                          active: false,
                          accent: _priority.color,
                          onTap: _pickPriority,
                        ),
                        _Chip(
                          label: _label.label,
                          active: false,
                          accent: _label.color,
                          onTap: _pickLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Says out loud which column the task will land in, so the
                    // start time stops being a guess.
                    Text(
                      _startsNow
                          ? AppStrings.landsInProgress
                          : AppStrings.landsScheduled(
                              AppDates.whenLabel(_start, DateTime.now()),
                            ),
                      style: AppTypography.meta.copyWith(
                        color: _startsNow
                            ? AppColors.statusInProgress
                            : AppColors.statusScheduled,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: AppTypography.fieldValue
                            .copyWith(color: AppColors.statusOverdue),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _submit,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: AppRadius.control,
                              ),
                              child: const Text(AppStrings.addTask,
                                  style: AppTypography.button),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.control,
                              border: Border.all(color: AppColors.borderStrong),
                            ),
                            child: const Icon(AppIcons.close,
                                size: 20, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickWhen() async {
    final picked = await showWhenPicker(
      context,
      title: AppStrings.whenStart,
      initial: _start,
    );
    if (picked?.value != null) setState(() => _start = picked!.value!);
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

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = AppStrings.titleRequired);
      return;
    }

    final description = _description.text.trim();
    final created = await ref.read(taskRepositoryProvider).createTask(
          title: title,
          description: description.isEmpty ? null : description,
          startDateTime: _start,
          priority: _priority,
          label: _label,
        );

    if (!mounted) return;
    Navigator.of(context).pop();
    // Drop any status filter so the new task is actually visible.
    ref.read(statusFilterProvider.notifier).state = null;
    ref.read(activeTabProvider.notifier).state = AppTab.home;
    ref.read(toastProvider.notifier).show(
          // Names the column it actually landed in — the status is decided by
          // the start time, not by a fixed default.
          AppStrings.taskAdded(created.status.label),
          duration: const Duration(milliseconds: 2400),
        );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.accent = AppColors.accent,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? accent.withValues(alpha: 0.12) : AppColors.surface3,
          borderRadius: AppRadius.pill,
          border: Border.all(
              color: active ? accent.withValues(alpha: 0.45) : AppColors.border),
        ),
        // Deliberately no `alignment:` — a Container that has one expands to
        // fill bounded constraints, which made every chip full-width and
        // stacked them one per row inside the Wrap. The min-size Row keeps the
        // chip hugging its label while still centring it vertically.
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.pill.copyWith(
                color: active ? accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
