import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';

/// Reads and writes app settings stored in `user_profiles.settings_json`.
class UserSettingsJsonStore {
  /// Creates store bound to the app database.
  const UserSettingsJsonStore(this._db);

  final AppDatabase _db;

  /// Loads the full settings JSON map.
  Future<Map<String, dynamic>> load() async {
    final row = await _db.select(_db.userProfiles).getSingleOrNull();
    if (row == null) {
      return <String, dynamic>{};
    }
    return Map<String, dynamic>.from(row.settingsJson);
  }

  /// Replaces or inserts the full settings map.
  Future<void> save(Map<String, dynamic> settings) async {
    await _db
        .into(_db.userProfiles)
        .insertOnConflictUpdate(
          UserProfilesCompanion(
            id: const Value(1),
            settingsJson: Value(Map<String, dynamic>.from(settings)),
          ),
        );
  }

  /// Applies [mutate] to current settings and persists result.
  Future<void> patch(void Function(Map<String, dynamic>) mutate) async {
    final current = await load();
    mutate(current);
    await save(current);
  }
}

/// Reusable read helper with optional one-time legacy migration.
Future<T> loadSettingWithLegacy<T>({
  required UserSettingsJsonStore store,
  required String key,
  required T fallback,
  required T? Function(Object? raw) parse,
  required Object? Function(T value) encode,
  Future<T?> Function()? loadLegacy,
}) async {
  final settings = await store.load();
  final parsed = parse(settings[key]);
  if (parsed != null) {
    return parsed;
  }

  if (loadLegacy != null) {
    final legacy = await loadLegacy();
    if (legacy != null) {
      await store.patch((json) => json[key] = encode(legacy));
      return legacy;
    }
  }

  return fallback;
}
