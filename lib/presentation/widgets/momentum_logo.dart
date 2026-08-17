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
  const MomentumMark({this.size = 22, this.glow = true, super.key});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MarkPainter(glow: glow)),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.glow});

  final bool glow;

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
    const sweep = _sweepDegrees * math.pi / 180;

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

    // Spark at the head of the ring — where the progress stopped.
    const head = start + sweep;
    canvas.drawCircle(
      box.center + Offset(math.cos(head), math.sin(head)) * _radius * unit,
      _sparkRadius * unit,
      Paint()..color = _tealHi,
    );

    final check = Path()..moveTo(_check.first.dx * unit, _check.first.dy * unit);
    for (final p in _check.skip(1)) {
      check.lineTo(p.dx * unit, p.dy * unit);
    }
    canvas.drawPath(
      check,
      Paint()
        ..color = AppColors.textPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = _checkStroke * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.glow != glow;
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
