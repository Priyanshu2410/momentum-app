import 'package:shared_preferences/shared_preferences.dart';

/// The two switches on the design's Settings sheet. Plain and isolate-safe so
/// the workmanager callback can read them too.
class SettingsService {
  const SettingsService();

  static const _autoPromoteKey = 'auto_promote';
  static const _pushKey = 'push_notifications';

  /// Minutes since midnight, or -1 for off. Stored as one int so there is no
  /// half-set state where the hour saved and the minute did not.
  static const _digestKey = 'daily_digest_minutes';

  Future<AppSettingsSnapshot> read() async {
    final prefs = await SharedPreferences.getInstance();
    final digest = prefs.getInt(_digestKey) ?? -1;
    return AppSettingsSnapshot(
      autoPromote: prefs.getBool(_autoPromoteKey) ?? true,
      pushEnabled: prefs.getBool(_pushKey) ?? true,
      digestMinutes: digest < 0 ? null : digest,
    );
  }

  Future<void> setAutoPromote(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_autoPromoteKey, value);

  Future<void> setPushEnabled(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_pushKey, value);

  /// [minutes] since midnight, or null to turn the digest off.
  Future<void> setDigestMinutes(int? minutes) async =>
      (await SharedPreferences.getInstance())
          .setInt(_digestKey, minutes ?? -1);
}

class AppSettingsSnapshot {
  const AppSettingsSnapshot({
    required this.autoPromote,
    required this.pushEnabled,
    this.digestMinutes,
  });

  const AppSettingsSnapshot.defaults()
      : autoPromote = true,
        pushEnabled = true,
        digestMinutes = null;

  final bool autoPromote;
  final bool pushEnabled;

  /// Time of the daily "still open" summary, in minutes since midnight.
  /// Null means the user has not asked for one.
  final int? digestMinutes;

  bool get digestEnabled => digestMinutes != null;

  /// Sentinel so copyWith can tell "leave it" from "switch it off".
  static const _unset = Object();

  AppSettingsSnapshot copyWith({
    bool? autoPromote,
    bool? pushEnabled,
    Object? digestMinutes = _unset,
  }) =>
      AppSettingsSnapshot(
        autoPromote: autoPromote ?? this.autoPromote,
        pushEnabled: pushEnabled ?? this.pushEnabled,
        digestMinutes: identical(digestMinutes, _unset)
            ? this.digestMinutes
            : digestMinutes as int?,
      );
}
