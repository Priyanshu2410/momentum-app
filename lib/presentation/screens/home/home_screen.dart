import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/board_filter_provider.dart';
import 'widgets/filter_bar.dart';
import 'widgets/kanban_board_view.dart';
import 'widgets/stat_cards.dart';
import 'widgets/task_list_view.dart';

/// Stat cards, filters, then either the grouped list or the Kanban board.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(homeViewProvider);

    return Column(
      children: [
        const StatCards(),
        const FilterBar(),
        Expanded(
          child: view == HomeView.list
              ? const TaskListView()
              : const KanbanBoardView(),
        ),
      ],
    );
  }
}
