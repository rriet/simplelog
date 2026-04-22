import 'dart:convert';

import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/user_settings_json.dart';
import 'package:simplelog/data/import/qatar_airways_import_options.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';
import 'package:simplelog/state/providers/flight_factoring_settings_provider.dart';

/// Persists CSV import options in `user_profiles.settings_json`.
class ImportOptionsPreferences {
  static const _simplePrefix = 'import.simplelog.';
  static const _qatarPrefix = 'import.qatar.';
  static const _swPrefix = 'import.southwest.';
  static const _swTypeMappingsKey = '${_swPrefix}aircraftTypeMappings';

  /// Loads import options used for legacy SimpleLog CSV files.
  static Future<SimpleLogImportOptions> loadSimpleLog(AppDatabase db) async {
    final store = UserSettingsJsonStore(db);
    final settings = await store.load();
    final factoringSettings = FlightFactoringSettings.fromJson(
      settings[flightFactoringSettingsKey] as String?,
    );

    bool boolSetting(String key, {bool fallback = false}) {
      return (settings[key] as bool?) ?? fallback;
    }

    return SimpleLogImportOptions(
      recalculateNightTime: boolSetting('${_simplePrefix}recalculateNightTime'),
      recalculateTotalTime: boolSetting('${_simplePrefix}recalculateTotalTime'),
      recalculateTakeoffLanding: boolSetting(
        '${_simplePrefix}recalculateTakeoffLanding',
      ),
      recalculateCrossCountry: boolSetting(
        '${_simplePrefix}recalculateCrossCountry',
      ),
      crossCountryThresholdNm: factoringSettings.crossCountryThresholdNm,
      recalculateIfrTime: boolSetting('${_simplePrefix}recalculateIfrTime'),
      ifrPercent: factoringSettings.ifrPercent,
      ifrMinimumMinutes: factoringSettings.ifrMinimumMinutes,
      ifrSubtractMinutes: factoringSettings.ifrSubtractMinutes,
      irp3Percent: factoringSettings.irp3Percent,
      irp3SubtractMinutes: factoringSettings.irp3SubtractMinutes,
      irp4Percent: factoringSettings.irp4Percent,
      irp4SubtractMinutes: factoringSettings.irp4SubtractMinutes,
      overrideAirportValues:
          (settings['${_simplePrefix}overrideAirportValues'] as bool?) ??
          ((settings['${_simplePrefix}overrideExistingValues'] as bool?) ??
              false),
      overrideAircraftValues:
          (settings['${_simplePrefix}overrideAircraftValues'] as bool?) ??
          ((settings['${_simplePrefix}overrideExistingValues'] as bool?) ??
              false),
      overrideAircraftTypeValues:
          (settings['${_simplePrefix}overrideAircraftTypeValues'] as bool?) ??
          ((settings['${_simplePrefix}overrideExistingValues'] as bool?) ??
              false),
    );
  }

  /// Saves import options used for legacy SimpleLog CSV files.
  static Future<void> saveSimpleLog(
    AppDatabase db,
    SimpleLogImportOptions value,
  ) async {
    final factoringSettings = FlightFactoringSettings(
      crossCountryThresholdNm: value.crossCountryThresholdNm,
      ifrPercent: value.ifrPercent,
      ifrMinimumMinutes: value.ifrMinimumMinutes,
      ifrSubtractMinutes: value.ifrSubtractMinutes,
      irp3Percent: value.irp3Percent,
      irp3SubtractMinutes: value.irp3SubtractMinutes,
      irp4Percent: value.irp4Percent,
      irp4SubtractMinutes: value.irp4SubtractMinutes,
    );

    await UserSettingsJsonStore(db).patch((settings) {
      settings['${_simplePrefix}recalculateNightTime'] =
          value.recalculateNightTime;
      settings['${_simplePrefix}recalculateTotalTime'] =
          value.recalculateTotalTime;
      settings['${_simplePrefix}recalculateTakeoffLanding'] =
          value.recalculateTakeoffLanding;
      settings['${_simplePrefix}recalculateCrossCountry'] =
          value.recalculateCrossCountry;
      settings['${_simplePrefix}recalculateIfrTime'] = value.recalculateIfrTime;
      settings['${_simplePrefix}overrideAirportValues'] =
          value.overrideAirportValues;
      settings['${_simplePrefix}overrideAircraftValues'] =
          value.overrideAircraftValues;
      settings['${_simplePrefix}overrideAircraftTypeValues'] =
          value.overrideAircraftTypeValues;
      settings[flightFactoringSettingsKey] = jsonEncode(
        factoringSettings.toJson(),
      );
    });
  }

  /// Loads import options used for Qatar Airways workbook files.
  static Future<QatarAirwaysImportOptions> loadQatarAirways({
    required AppDatabase db,
    CrewPosition fallbackPosition = CrewPosition.sic,
  }) async {
    final settings = await UserSettingsJsonStore(db).load();
    return QatarAirwaysImportOptions(
      defaultPosition:
          _parseCrewPosition(
            settings['${_qatarPrefix}defaultPosition'] as String?,
          ) ??
          fallbackPosition,
      myName: (settings['${_qatarPrefix}myName'] as String?) ?? '',
    );
  }

  /// Saves import options used for Qatar Airways workbook files.
  static Future<void> saveQatarAirways(
    AppDatabase db,
    QatarAirwaysImportOptions value,
  ) async {
    await UserSettingsJsonStore(db).patch((settings) {
      settings['${_qatarPrefix}defaultPosition'] = value.defaultPosition.name;
      settings['${_qatarPrefix}myName'] = value.myName;
    });
  }

  /// Loads import options used for Southwest CSV files.
  static Future<SouthwestImportOptions> loadSouthwest({
    required AppDatabase db,
    CrewPosition fallbackPosition = CrewPosition.sic,
  }) async {
    final settings = await UserSettingsJsonStore(db).load();
    return SouthwestImportOptions(
      defaultSelfPosition:
          _parseCrewPosition(
            settings['${_swPrefix}defaultSelfPosition'] as String?,
          ) ??
          fallbackPosition,
      recalculateBlockTime:
          (settings['${_swPrefix}recalculateBlockTime'] as bool?) ?? true,
      recalculateNightTime:
          (settings['${_swPrefix}recalculateNightTime'] as bool?) ?? true,
      recalculateIfrTime:
          (settings['${_swPrefix}recalculateIfrTime'] as bool?) ?? true,
      ifrPercent: (settings['${_swPrefix}ifrPercent'] as num?)?.toInt() ?? 100,
      ifrSubtractMinutes:
          (settings['${_swPrefix}ifrSubtractMinutes'] as num?)?.toInt() ?? 0,
      ifrMinimumMinutes:
          (settings['${_swPrefix}ifrMinimumMinutes'] as num?)?.toInt() ?? 0,
      recalculateCrossCountry:
          (settings['${_swPrefix}recalculateCrossCountry'] as bool?) ?? true,
      crossCountryThresholdNm:
          (settings['${_swPrefix}crossCountryThresholdNm'] as int?) ?? 50,
      overrideExistingData:
          (settings['${_swPrefix}overrideExistingData'] as bool?) ?? false,
      addCopilotStaffNumberToNotes:
          (settings['${_swPrefix}addCopilotStaffNumberToNotes'] as bool?) ??
          true,
      addFlightNumberToNotes:
          (settings['${_swPrefix}addFlightNumberToNotes'] as bool?) ?? true,
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
      settings['${_swPrefix}defaultSelfPosition'] =
          value.defaultSelfPosition.name;
      settings['${_swPrefix}recalculateBlockTime'] = value.recalculateBlockTime;
      settings['${_swPrefix}recalculateNightTime'] = value.recalculateNightTime;
      settings['${_swPrefix}recalculateIfrTime'] = value.recalculateIfrTime;
      settings['${_swPrefix}ifrPercent'] = value.ifrPercent;
      settings['${_swPrefix}ifrSubtractMinutes'] = value.ifrSubtractMinutes;
      settings['${_swPrefix}ifrMinimumMinutes'] = value.ifrMinimumMinutes;
      settings['${_swPrefix}recalculateCrossCountry'] =
          value.recalculateCrossCountry;
      settings['${_swPrefix}crossCountryThresholdNm'] =
          value.crossCountryThresholdNm;
      settings['${_swPrefix}overrideExistingData'] = value.overrideExistingData;
      settings['${_swPrefix}addCopilotStaffNumberToNotes'] =
          value.addCopilotStaffNumberToNotes;
      settings['${_swPrefix}addFlightNumberToNotes'] =
          value.addFlightNumberToNotes;
      settings[_swTypeMappingsKey] = <String, String>{
        for (final entry in value.aircraftTypeMappings.entries)
          _normalizeSouthwestTypeCode(entry.key): _normalizeSouthwestTypeCode(
            entry.value,
          ),
      };
    });
  }
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

CrewPosition? _parseCrewPosition(String? raw) {
  if (raw == null) return null;
  for (final value in CrewPosition.values) {
    if (value.name == raw && value != CrewPosition.unknown) return value;
  }
  return null;
}
