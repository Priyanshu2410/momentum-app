import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// 46px completion ring in the header. Sweeps up from empty on first build and
/// animates between values afterwards.
class ProgressRing extends StatelessWidget {
  const ProgressRing({required this.progress, super.key});

  /// 0..1
  final double progress;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: 46,
        height: 46,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeInOutCubic,
          builder: (context, value, _) => CustomPaint(
            painter: _RingPainter(value),
            child: Center(
              child: Text(
                '${(value * 100).round()}%',
                style: AppTypography.chip.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.progress);

  final double progress;

  static const _radius = 19.0;
  static const _stroke = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = const Color(0x12FFFFFF); // rgba(255,255,255,0.07)
    canvas.drawCircle(center, _radius, track);

    if (progress <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.accent;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: _radius),
      -math.pi / 2, // 12 o'clock
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
