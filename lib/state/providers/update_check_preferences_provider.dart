import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _checkForUpdatesKey = 'check_for_updates';
const _skippedVersionKey = 'skipped_version';

/// Default value: true for direct builds, false for store builds.
bool get _defaultCheckForUpdates =>
    !kIsWeb && defaultTargetPlatform != TargetPlatform.iOS;

/// SharedPreferences instance provider.
final _sharedPrefsProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

/// Whether the "check for updates on startup" toggle is enabled.
final checkForUpdatesProvider =
    AsyncNotifierProvider<CheckForUpdatesNotifier, bool>(
  CheckForUpdatesNotifier.new,
);

/// Manages the check-for-updates preference.
class CheckForUpdatesNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await ref.read(_sharedPrefsProvider.future);
    return prefs.getBool(_checkForUpdatesKey) ?? _defaultCheckForUpdates;
  }

  /// Updates the preference and in-memory state.
  Future<void> toggle({required bool value}) async {
    final prefs = await ref.read(_sharedPrefsProvider.future);
    await prefs.setBool(_checkForUpdatesKey, value);
    state = AsyncData(value);
  }
}

/// The version the user chose to skip (null means none skipped).
final skippedVersionProvider =
    AsyncNotifierProvider<SkippedVersionNotifier, String?>(
  SkippedVersionNotifier.new,
);

/// Manages the skipped version preference.
class SkippedVersionNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final prefs = await ref.read(_sharedPrefsProvider.future);
    return prefs.getString(_skippedVersionKey);
  }

  /// Records the version the user chose to skip.
  Future<void> skip(String version) async {
    final prefs = await ref.read(_sharedPrefsProvider.future);
    await prefs.setString(_skippedVersionKey, version);
    state = AsyncData(version);
  }

  /// Clears the skipped version so the update will be shown again.
  Future<void> clear() async {
    final prefs = await ref.read(_sharedPrefsProvider.future);
    await prefs.remove(_skippedVersionKey);
    state = const AsyncData(null);
  }
}
