import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/task.dart';
import '../../../../domain/enums/task_status.dart';
import '../../../providers/tasks_provider.dart';
import '../../../providers/ui_feedback_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';
import '../../task_detail/task_detail_sheet.dart';
import 'task_card.dart';

/// Horizontally snapping Kanban columns, one per status, in the design's
/// order. The next column peeks at the right edge.
class KanbanBoardView extends ConsumerStatefulWidget {
  const KanbanBoardView({super.key});

  @override
  ConsumerState<KanbanBoardView> createState() => _KanbanBoardViewState();
}

class _KanbanBoardViewState extends ConsumerState<KanbanBoardView> {
  PageController? _controller;
  double _fraction = 0;

  /// Rebuilt here rather than in `build` — swapping a live PageController
  /// mid-build would dispose one the current PageView is still attached to.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Column + gutter as a share of the viewport, so the next column peeks by
    // the same proportion the design shows at 402pt.
    final viewport = MediaQuery.sizeOf(context).width - AppSpacing.xl * 2;
    final fraction =
        ((AppSpacing.boardColumnWidth + AppSpacing.boardColumnGap) / viewport)
            .clamp(0.5, 1.0);
    if (fraction == _fraction) return;

    _fraction = fraction;
    _controller?.dispose();
    _controller = PageController(viewportFraction: fraction);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = ref.watch(groupedTasksProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: TaskStatus.values.length,
        itemBuilder: (context, i) {
          final status = TaskStatus.values[i];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.boardColumnGap),
            child: _KanbanColumn(status: status, tasks: grouped[status]!),
          );
        },
      ),
    );
  }
}

/// Keeps its scroll offset and stays alive while other columns are swiped past.
class _KanbanColumn extends ConsumerStatefulWidget {
  const _KanbanColumn({required this.status, required this.tasks});

  final TaskStatus status;
  final List<Task> tasks;

  @override
  ConsumerState<_KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends ConsumerState<_KanbanColumn>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final pulsing = ref.watch(pulseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 4, 2, AppSpacing.md),
          child: SectionHeader(
            title: widget.status.label,
            color: widget.status.color,
            count: widget.tasks.length,
            countOnRight: true,
            showRule: false,
          ),
        ),
        Expanded(
          child: widget.tasks.isEmpty
              ? const SingleChildScrollView(
                  child: EmptyState(title: AppStrings.nothingHere, compact: true),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                      bottom: AppSpacing.listBottomInset),
                  itemCount: widget.tasks.length,
                  itemBuilder: (context, i) {
                    final task = widget.tasks[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CompactTaskCard(
                        task: task,
                        index: i,
                        pulsing: pulsing.contains(task.id),
                        onOpen: () => showTaskDetailSheet(context, ref, task.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
