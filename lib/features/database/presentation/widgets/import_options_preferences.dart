import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/user_settings_json.dart';
import 'package:simplelog/data/import/qatar_airways_import_options.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';
import 'package:simplelog/data/import/wader_import_options.dart';

/// Persists CSV import options in `user_profiles.settings_json`.
class ImportOptionsPreferences {
  static const _swPrefix = 'import.southwest.';
  static const _swTypeMappingsKey = '${_swPrefix}aircraftTypeMappings';

  /// Loads import options used for legacy SimpleLog CSV files.
  static Future<SimpleLogImportOptions> loadSimpleLog(AppDatabase db) async {
    return const SimpleLogImportOptions();
  }

  /// Saves import options used for legacy SimpleLog CSV files.
  static Future<void> saveSimpleLog(
    AppDatabase db,
    SimpleLogImportOptions value,
  ) async {}

  /// Loads import options used for Qatar Airways workbook files.
  static Future<QatarAirwaysImportOptions> loadQatarAirways({
    required AppDatabase db,
    CrewPosition fallbackPosition = CrewPosition.sic,
  }) async => QatarAirwaysImportOptions(defaultPosition: fallbackPosition);

  /// Saves import options used for Qatar Airways workbook files.
  static Future<void> saveQatarAirways(
    AppDatabase db,
    QatarAirwaysImportOptions value,
  ) async {}

  /// Loads import options used for Southwest CSV files.
  static Future<SouthwestImportOptions> loadSouthwest({
    required AppDatabase db,
    CrewPosition fallbackPosition = CrewPosition.sic,
  }) async {
    final settings = await UserSettingsJsonStore(db).load();
    return SouthwestImportOptions(
      defaultSelfPosition: fallbackPosition,
      aircraftTypeMappings: _parseSouthwestTypeMappings(
        settings[_swTypeMappingsKey],
      ),
    );
  }

  /// Saves import options used for Southwest CSV files.
  static Future<void> saveSouthwest(
    AppDatabase db,
    SouthwestImportOptions value,
  ) async {
    await UserSettingsJsonStore(db).patch((settings) {
      settings[_swTypeMappingsKey] = <String, String>{
        for (final entry in value.aircraftTypeMappings.entries)
          _normalizeSouthwestTypeCode(entry.key): _normalizeSouthwestTypeCode(
            entry.value,
          ),
      };
    });
  }

  /// Loads import options used for Wader CSV files.
  static Future<WaderImportOptions> loadWader({
    required AppDatabase db,
  }) async => const WaderImportOptions();

  /// Saves import options used for Wader CSV files.
  static Future<void> saveWader(
    AppDatabase db,
    WaderImportOptions value,
  ) async {}
}

Map<String, String> _parseSouthwestTypeMappings(Object? raw) {
  if (raw is! Map) {
    return const <String, String>{};
  }
  final mapped = <String, String>{};
  for (final entry in raw.entries) {
    final key = _normalizeSouthwestTypeCode(entry.key.toString());
    final value = _normalizeSouthwestTypeCode(entry.value?.toString() ?? '');
    if (value.isEmpty) {
      continue;
    }
    mapped[key] = value;
  }
  return mapped;
}

String _normalizeSouthwestTypeCode(String value) {
  return value.trim().toUpperCase();
}
