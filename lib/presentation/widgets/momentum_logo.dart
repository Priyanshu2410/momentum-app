import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// The Momentum mark: a progress ring closing on a check, with a bright spark
/// at the head of the ring.
///
/// The same geometry is baked into the launcher and notification icons by
/// `tool/gen_icons.py` — the constants below are the contract between the two,
/// so change both together.
///
/// Drawn rather than shipped as an asset: an arc, a dot and three points.
class MomentumMark extends StatelessWidget {
  const MomentumMark({
    this.size = 22,
    this.glow = true,
    this.progress = 1,
    super.key,
  });

  final double size;
  final bool glow;

  /// 0 draws nothing, 1 draws the finished mark. Between the two the ring
  /// sweeps round and the check strokes in behind it — see [MomentumSplash].
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _MarkPainter(glow: glow, progress: progress),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.glow, this.progress = 1});

  final bool glow;
  final double progress;

  // Geometry, in the 0..100 box the icon generator uses.
  static const _centre = Offset(50, 50);
  static const _radius = 33.0;
  static const _ringStroke = 8.5;
  static const _sparkRadius = 4.25;

  /// 320° of ring, leaving a 40° gap centred on the bottom. Flutter angles run
  /// clockwise from 3 o'clock, so bottom is 90°.
  static const _startDegrees = 110.0;
  static const _sweepDegrees = 320.0;

  static const _check = [Offset(34, 51), Offset(45, 62), Offset(67, 38)];
  static const _checkStroke = 9.0;

  static const _tealHi = Color(0xFF63F0D0);
  static const _tealLo = Color(0xFF129E86);

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 100;
    final box = Rect.fromCircle(
      center: _centre * unit,
      radius: _radius * unit,
    );
    const start = _startDegrees * math.pi / 180;
    const fullSweep = _sweepDegrees * math.pi / 180;
    final ringT = (progress / 0.7).clamp(0.0, 1.0);
    final sweep = fullSweep * ringT;
    // Overlaps the ring's last stretch, so it reads as one gesture.
    final checkT = ((progress - 0.55) / 0.45).clamp(0.0, 1.0);

    final ring = Paint()
      ..shader = const LinearGradient(colors: [_tealHi, _tealLo])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringStroke * unit
      ..strokeCap = StrokeCap.round;

    if (glow) {
      canvas.drawArc(
        box,
        start,
        sweep,
        false,
        Paint.from(ring)
          ..shader = null
          ..color = _tealHi.withValues(alpha: 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.09),
      );
    }
    canvas.drawArc(box, start, sweep, false, ring);

    // Spark rides the head of the ring while it draws.
    final head = start + sweep;
    canvas.drawCircle(
      box.center + Offset(math.cos(head), math.sin(head)) * _radius * unit,
      _sparkRadius * unit,
      Paint()..color = _tealHi,
    );

    if (checkT <= 0) return;

    final check = Path()..moveTo(_check.first.dx * unit, _check.first.dy * unit);
    for (final p in _check.skip(1)) {
      check.lineTo(p.dx * unit, p.dy * unit);
    }

    final checkPaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = _checkStroke * unit
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (checkT >= 1) {
      canvas.drawPath(check, checkPaint);
      return;
    }
    // Trim the path instead of fading it, so the tick is drawn on rather than
    // appearing all at once.
    for (final metric in check.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * checkT),
        checkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.glow != glow || old.progress != progress;
}

/// Mark plus wordmark, centred — the brand strip that sits above every tab.
class MomentumLogo extends StatelessWidget {
  const MomentumLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MomentumMark(size: 24),
          const SizedBox(width: 9),
          Text(
            'momentum',
            style: AppTypography.sectionHeader.copyWith(
              fontSize: 13,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
