import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An update waiting on GitHub Releases.
class AppUpdate {
  const AppUpdate({
    required this.version,
    required this.notes,
    required this.downloadUrl,
  });

  final String version;
  final String notes;

  /// Direct link to the release's `.apk` asset. Opening it hands the file to
  /// the browser, which hands it to Android's package installer.
  final String downloadUrl;
}

/// Checks GitHub Releases for a newer build.
///
/// Both identifiers are baked in at build time by the release workflow
/// (`--dart-define`). A local build has neither, which switches the whole
/// feature off — no "update available" noise while developing.
class UpdateService {
  const UpdateService();

  static const repo = String.fromEnvironment('UPDATE_REPO');
  static const currentVersion = String.fromEnvironment('APP_VERSION');

  static const _lastCheckKey = 'update_last_check';
  static const _checkInterval = Duration(hours: 24);

  bool get enabled => repo.isNotEmpty && currentVersion.isNotEmpty;

  /// Throttled to once a day — called on every app start. Returns null when
  /// there is nothing new, when it is too soon to ask, or on any failure: an
  /// update check is never worth interrupting the app over.
  Future<AppUpdate?> checkOnLaunch() async {
    if (!enabled) return null;

    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_lastCheckKey);
    if (last != null) {
      final since = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(last),
      );
      if (since < _checkInterval) return null;
    }
    final update = await check();
    // Stamped only after the call came back, so a launch with no signal does
    // not burn the day's one check.
    await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
    return update;
  }

  /// Unthrottled — what the Settings row calls. Throws nothing; logs instead.
  Future<AppUpdate?> check() async {
    if (!enabled) return null;

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(
        Uri.https('api.github.com', '/repos/$repo/releases/latest'),
      );
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        // GitHub rejects API calls without one.
        ..set(HttpHeaders.userAgentHeader, 'momentum-app');

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        _log('releases/latest returned ${response.statusCode}');
        return null;
      }

      final body = await response.transform(utf8.decoder).join();
      return parseRelease(body, currentVersion);
    } on Object catch (e) {
      // Offline, DNS failure, rate limited — all the same non-event.
      _log('check failed: $e');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  /// Split out from the network so it can be tested against a real payload.
  /// Returns null unless the release is newer *and* ships an APK.
  @visibleForTesting
  static AppUpdate? parseRelease(String body, String current) {
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) return null;
    if (json['draft'] == true || json['prerelease'] == true) return null;

    final tag = json['tag_name'] as String?;
    if (tag == null || !isNewer(tag, current)) return null;

    final assets = json['assets'];
    if (assets is! List) return null;
    final apk = assets.cast<Map<String, dynamic>>().firstWhere(
          (a) => (a['name'] as String? ?? '').endsWith('.apk'),
          orElse: () => const {},
        );
    final url = apk['browser_download_url'] as String?;
    if (url == null) return null;

    return AppUpdate(
      version: normalize(tag),
      notes: (json['body'] as String? ?? '').trim(),
      downloadUrl: url,
    );
  }

  /// Strips a leading `v` and any `+build` suffix: `v1.2.0` and `1.2.0+7` both
  /// normalise to `1.2.0`.
  @visibleForTesting
  static String normalize(String version) {
    final trimmed = version.trim();
    final bare = trimmed.startsWith('v') ? trimmed.substring(1) : trimmed;
    return bare.split('+').first;
  }

  /// Numeric, part by part, so 1.10.0 beats 1.9.0. A part that will not parse
  /// counts as 0 rather than throwing — a malformed tag must not crash a
  /// background check.
  @visibleForTesting
  static bool isNewer(String candidate, String current) {
    final a = normalize(candidate).split('.');
    final b = normalize(current).split('.');
    for (var i = 0; i < (a.length > b.length ? a.length : b.length); i++) {
      final x = i < a.length ? int.tryParse(a[i]) ?? 0 : 0;
      final y = i < b.length ? int.tryParse(b[i]) ?? 0 : 0;
      if (x != y) return x > y;
    }
    return false;
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[update] $message');
  }
}
