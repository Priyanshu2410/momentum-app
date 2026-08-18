import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings_service.dart';
import 'app_providers.dart';

/// Starts on the defaults and swaps in the stored values once the read
/// completes, so the Settings sheet never has to show a spinner.
class SettingsNotifier extends Notifier<AppSettingsSnapshot> {
  @override
  AppSettingsSnapshot build() {
    _load();
    return const AppSettingsSnapshot.defaults();
  }

  SettingsService get _service => ref.read(settingsServiceProvider);

  Future<void> _load() async => state = await _service.read();

  Future<void> setAutoPromote(bool value) async {
    state = state.copyWith(autoPromote: value);
    await _service.setAutoPromote(value);
  }

  Future<void> setPushEnabled(bool value) async {
    state = state.copyWith(pushEnabled: value);
    await _service.setPushEnabled(value);
    await _rearmDigest();
  }

  /// [minutes] since midnight, or null to switch the digest off.
  Future<void> setDigestMinutes(int? minutes) async {
    state = state.copyWith(digestMinutes: minutes);
    await _service.setDigestMinutes(minutes);
    await _rearmDigest();
  }

  /// A scheduler pass is what actually hands the digest to the OS, so changing
  /// the time has to run one — otherwise nothing happens until the next
  /// 15-minute job.
  Future<void> _rearmDigest() async {
    await ref.read(taskSchedulerProvider).sync(settings: state);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettingsSnapshot>(
  SettingsNotifier.new,
);
