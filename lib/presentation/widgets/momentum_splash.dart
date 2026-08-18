import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'momentum_logo.dart';

/// Draws the mark on, then gets out of the way.
///
/// [child] is built and mounted underneath from the first frame, so the
/// database opens and the task streams fill while the animation plays — the
/// splash costs no startup time, it just covers the frames that would otherwise
/// be an empty board.
class MomentumSplash extends StatefulWidget {
  const MomentumSplash({required this.child, super.key});

  final Widget child;

  @override
  State<MomentumSplash> createState() => _MomentumSplashState();
}

class _MomentumSplashState extends State<MomentumSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1650),
    vsync: this,
  )..forward();

  /// The mark draws over the first stretch, then the whole cover fades.
  late final Animation<double> _draw = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.62, curve: Curves.easeInOutCubic),
  );

  late final Animation<double> _wordmark = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
  );

  late final Animation<double> _cover = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.82, 1, curve: Curves.easeIn),
  );

  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      // Dropping the overlay entirely once it is invisible keeps a full-screen
      // opacity layer out of every later frame.
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _done = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => IgnorePointer(
              child: Opacity(
                opacity: 1 - _cover.value,
                child: ColoredBox(
                  color: AppColors.background,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MomentumMark(size: 92, progress: _draw.value),
                        const SizedBox(height: 22),
                        Opacity(
                          opacity: _wordmark.value,
                          child: Text(
                            'momentum',
                            style: AppTypography.sectionHeader.copyWith(
                              fontSize: 15,
                              letterSpacing: 4,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
