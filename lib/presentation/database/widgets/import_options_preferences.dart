import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';

class ImportOptionsPreferences {
  static const _simplePrefix = 'import.simplelog.';
  static const _swPrefix = 'import.southwest.';

  static Future<SimpleLogImportOptions> loadSimpleLog() async {
    final prefs = await SharedPreferences.getInstance();
    return SimpleLogImportOptions(
      recalculateNightTime:
          prefs.getBool('${_simplePrefix}recalculateNightTime') ?? false,
      recalculateTotalTime:
          prefs.getBool('${_simplePrefix}recalculateTotalTime') ?? false,
      recalculateTakeoffLanding:
          prefs.getBool('${_simplePrefix}recalculateTakeoffLanding') ?? false,
      recalculateCrossCountry:
          prefs.getBool('${_simplePrefix}recalculateCrossCountry') ?? false,
      crossCountryThresholdNm:
          prefs.getInt('${_simplePrefix}crossCountryThresholdNm') ?? 50,
      recalculateInstrument:
          prefs.getBool('${_simplePrefix}recalculateInstrument') ?? false,
      instrumentPercent:
          prefs.getInt('${_simplePrefix}instrumentPercent') ?? 0,
      instrumentMinimumMinutes:
          prefs.getInt('${_simplePrefix}instrumentMinimumMinutes') ?? 0,
      instrumentSubtractMinutes:
          prefs.getInt('${_simplePrefix}instrumentSubtractMinutes') ?? 0,
      airportStrategy: _parseMerge(
            prefs.getString('${_simplePrefix}airportStrategy'),
          ) ??
          MergeStrategy.keep,
      crewStrategy:
          _parseMerge(prefs.getString('${_simplePrefix}crewStrategy')) ??
              MergeStrategy.keep,
      aircraftStrategy:
          _parseMerge(prefs.getString('${_simplePrefix}aircraftStrategy')) ??
              MergeStrategy.keep,
      aircraftTypeStrategy:
          _parseMerge(prefs.getString('${_simplePrefix}aircraftTypeStrategy')) ??
              MergeStrategy.keep,
    );
  }

  static Future<void> saveSimpleLog(SimpleLogImportOptions value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      '${_simplePrefix}recalculateNightTime',
      value.recalculateNightTime,
    );
    await prefs.setBool(
      '${_simplePrefix}recalculateTotalTime',
      value.recalculateTotalTime,
    );
    await prefs.setBool(
      '${_simplePrefix}recalculateTakeoffLanding',
      value.recalculateTakeoffLanding,
    );
    await prefs.setBool(
      '${_simplePrefix}recalculateCrossCountry',
      value.recalculateCrossCountry,
    );
    await prefs.setInt(
      '${_simplePrefix}crossCountryThresholdNm',
      value.crossCountryThresholdNm,
    );
    await prefs.setBool(
      '${_simplePrefix}recalculateInstrument',
      value.recalculateInstrument,
    );
    await prefs.setInt(
      '${_simplePrefix}instrumentPercent',
      value.instrumentPercent,
    );
    await prefs.setInt(
      '${_simplePrefix}instrumentMinimumMinutes',
      value.instrumentMinimumMinutes,
    );
    await prefs.setInt(
      '${_simplePrefix}instrumentSubtractMinutes',
      value.instrumentSubtractMinutes,
    );
    await prefs.setString(
      '${_simplePrefix}airportStrategy',
      value.airportStrategy.name,
    );
    await prefs.setString(
      '${_simplePrefix}crewStrategy',
      value.crewStrategy.name,
    );
    await prefs.setString(
      '${_simplePrefix}aircraftStrategy',
      value.aircraftStrategy.name,
    );
    await prefs.setString(
      '${_simplePrefix}aircraftTypeStrategy',
      value.aircraftTypeStrategy.name,
    );
  }

  static Future<SouthwestImportOptions> loadSouthwest({
    CrewPosition fallbackPosition = CrewPosition.sic,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return SouthwestImportOptions(
      defaultSelfPosition:
          _parseCrewPosition(prefs.getString('${_swPrefix}defaultSelfPosition')) ??
              fallbackPosition,
      recalculateBlockTime:
          prefs.getBool('${_swPrefix}recalculateBlockTime') ?? true,
      recalculateNightTime:
          prefs.getBool('${_swPrefix}recalculateNightTime') ?? true,
      recalculateIfrTime:
          prefs.getBool('${_swPrefix}recalculateIfrTime') ?? true,
      recalculateCrossCountry:
          prefs.getBool('${_swPrefix}recalculateCrossCountry') ?? true,
      crossCountryThresholdNm:
          prefs.getInt('${_swPrefix}crossCountryThresholdNm') ?? 50,
      recalculateInstrumentTime:
          prefs.getBool('${_swPrefix}recalculateInstrumentTime') ?? false,
      overrideExistingData:
          prefs.getBool('${_swPrefix}overrideExistingData') ?? false,
      addCopilotStaffNumberToNotes:
          prefs.getBool('${_swPrefix}addCopilotStaffNumberToNotes') ?? true,
      addFlightNumberToNotes:
          prefs.getBool('${_swPrefix}addFlightNumberToNotes') ?? true,
    );
  }

  static Future<void> saveSouthwest(SouthwestImportOptions value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_swPrefix}defaultSelfPosition',
      value.defaultSelfPosition.name,
    );
    await prefs.setBool(
      '${_swPrefix}recalculateBlockTime',
      value.recalculateBlockTime,
    );
    await prefs.setBool(
      '${_swPrefix}recalculateNightTime',
      value.recalculateNightTime,
    );
    await prefs.setBool(
      '${_swPrefix}recalculateIfrTime',
      value.recalculateIfrTime,
    );
    await prefs.setBool(
      '${_swPrefix}recalculateCrossCountry',
      value.recalculateCrossCountry,
    );
    await prefs.setInt(
      '${_swPrefix}crossCountryThresholdNm',
      value.crossCountryThresholdNm,
    );
    await prefs.setBool(
      '${_swPrefix}recalculateInstrumentTime',
      value.recalculateInstrumentTime,
    );
    await prefs.setBool(
      '${_swPrefix}overrideExistingData',
      value.overrideExistingData,
    );
    await prefs.setBool(
      '${_swPrefix}addCopilotStaffNumberToNotes',
      value.addCopilotStaffNumberToNotes,
    );
    await prefs.setBool(
      '${_swPrefix}addFlightNumberToNotes',
      value.addFlightNumberToNotes,
    );
  }
}

MergeStrategy? _parseMerge(String? raw) {
  if (raw == null) return null;
  for (final value in MergeStrategy.values) {
    if (value.name == raw) return value;
  }
  return null;
}

CrewPosition? _parseCrewPosition(String? raw) {
  if (raw == null) return null;
  for (final value in CrewPosition.values) {
    if (value.name == raw && value != CrewPosition.unknown) return value;
  }
  return null;
}
