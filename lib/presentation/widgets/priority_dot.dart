import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_status.dart';

/// 8px priority dot. While [pulsing] — the moment a task auto-promotes — the
/// status colour rings out behind it and the dot itself beats twice.
class PriorityDot extends StatelessWidget {
  const PriorityDot({
    required this.priority,
    required this.status,
    this.pulsing = false,
    super.key,
  });

  final TaskPriority priority;
  final TaskStatus status;
  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: priority.color,
        shape: BoxShape.circle,
      ),
    );

    if (!pulsing) return dot;

    // RepaintBoundary keeps the ring off the rest of the card's layer.
    return RepaintBoundary(
      child: SizedBox(
        width: 8,
        height: 8,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: status.color,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat(count: 2))
                .scaleXY(begin: 1, end: 3.8, duration: 1100.ms, curve: Curves.easeOut)
                .fadeOut(duration: 1100.ms),
            dot
                .animate(onPlay: (c) => c.repeat(count: 2))
                .scaleXY(begin: 1, end: 1.45, duration: 405.ms, curve: Curves.easeOut)
                .then()
                .scaleXY(begin: 1.45, end: 1, duration: 495.ms),
          ],
        ),
      ),
    );
  }
}
