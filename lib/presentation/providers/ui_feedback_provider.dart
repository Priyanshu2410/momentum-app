import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ids of cards that just auto-promoted. The board pulses them, then clears
/// itself after the animation window from the design (1.4s).
class PulseNotifier extends Notifier<Set<int>> {
  Timer? _timer;

  @override
  Set<int> build() {
    ref.onDispose(() => _timer?.cancel());
    return const {};
  }

  void pulse(Iterable<int> ids) {
    if (ids.isEmpty) return;
    state = {...state, ...ids};
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1400), () => state = const {});
  }
}

final pulseProvider = NotifierProvider<PulseNotifier, Set<int>>(
  PulseNotifier.new,
);

/// The design's floating top toast. Null means nothing is showing.
class ToastNotifier extends Notifier<String?> {
  Timer? _timer;

  @override
  String? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void show(String message, {Duration duration = const Duration(seconds: 3)}) {
    state = message;
    _timer?.cancel();
    _timer = Timer(duration, () => state = null);
  }

  void dismiss() {
    _timer?.cancel();
    state = null;
  }
}

final toastProvider = NotifierProvider<ToastNotifier, String?>(
  ToastNotifier.new,
);

/// Task id a notification tap wants opened. The shell consumes and clears it.
final pendingTaskIdProvider = StateProvider<int?>((ref) => null);

/// True while any bottom sheet is up. Rotates the FAB's plus into a cross.
final sheetOpenProvider = StateProvider<bool>((ref) => false);
