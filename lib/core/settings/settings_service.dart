import 'package:shared_preferences/shared_preferences.dart';

/// The two switches on the design's Settings sheet. Plain and isolate-safe so
/// the workmanager callback can read them too.
class SettingsService {
  const SettingsService();

  static const _autoPromoteKey = 'auto_promote';
  static const _pushKey = 'push_notifications';

  Future<AppSettingsSnapshot> read() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettingsSnapshot(
      autoPromote: prefs.getBool(_autoPromoteKey) ?? true,
      pushEnabled: prefs.getBool(_pushKey) ?? true,
    );
  }

  Future<void> setAutoPromote(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_autoPromoteKey, value);

  Future<void> setPushEnabled(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_pushKey, value);
}

class AppSettingsSnapshot {
  const AppSettingsSnapshot({
    required this.autoPromote,
    required this.pushEnabled,
  });

  const AppSettingsSnapshot.defaults()
      : autoPromote = true,
        pushEnabled = true;

  final bool autoPromote;
  final bool pushEnabled;

  AppSettingsSnapshot copyWith({bool? autoPromote, bool? pushEnabled}) =>
      AppSettingsSnapshot(
        autoPromote: autoPromote ?? this.autoPromote,
        pushEnabled: pushEnabled ?? this.pushEnabled,
      );
}
