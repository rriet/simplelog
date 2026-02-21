import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';
import 'package:simplelog/state/providers/flight_factoring_settings_provider.dart';

class ImportOptionsPreferences {
  static const _simplePrefix = 'import.simplelog.';
  static const _swPrefix = 'import.southwest.';

  static Future<SimpleLogImportOptions> loadSimpleLog() async {
    final prefs = await SharedPreferences.getInstance();
    final factoringSettings = FlightFactoringSettings.fromJson(
      prefs.getString(flightFactoringSettingsKey),
    );
    return SimpleLogImportOptions(
      recalculateNightTime:
          prefs.getBool('${_simplePrefix}recalculateNightTime') ?? false,
      recalculateTotalTime:
          prefs.getBool('${_simplePrefix}recalculateTotalTime') ?? false,
      recalculateTakeoffLanding:
          prefs.getBool('${_simplePrefix}recalculateTakeoffLanding') ?? false,
      recalculateCrossCountry:
          prefs.getBool('${_simplePrefix}recalculateCrossCountry') ?? false,
      crossCountryThresholdNm: factoringSettings.crossCountryThresholdNm,
      recalculateInstrument:
          prefs.getBool('${_simplePrefix}recalculateInstrument') ?? false,
      instrumentPercent: factoringSettings.instrumentPercent,
      instrumentMinimumMinutes: factoringSettings.instrumentMinimumMinutes,
      instrumentSubtractMinutes: factoringSettings.instrumentSubtractMinutes,
      recalculateIfrTime:
          prefs.getBool('${_simplePrefix}recalculateIfrTime') ?? false,
      ifrPercent: factoringSettings.ifrPercent,
      ifrMinimumMinutes: factoringSettings.ifrMinimumMinutes,
      ifrSubtractMinutes: factoringSettings.ifrSubtractMinutes,
      irp3Percent: factoringSettings.irp3Percent,
      irp3SubtractMinutes: factoringSettings.irp3SubtractMinutes,
      irp4Percent: factoringSettings.irp4Percent,
      irp4SubtractMinutes: factoringSettings.irp4SubtractMinutes,
      overrideAirportValues:
          prefs.getBool('${_simplePrefix}overrideAirportValues') ??
          (prefs.getBool('${_simplePrefix}overrideExistingValues') ?? false),
      overrideAircraftValues:
          prefs.getBool('${_simplePrefix}overrideAircraftValues') ??
          (prefs.getBool('${_simplePrefix}overrideExistingValues') ?? false),
      overrideAircraftTypeValues:
          prefs.getBool('${_simplePrefix}overrideAircraftTypeValues') ??
          (prefs.getBool('${_simplePrefix}overrideExistingValues') ?? false),
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
    await prefs.setBool(
      '${_simplePrefix}recalculateInstrument',
      value.recalculateInstrument,
    );
    await prefs.setBool(
      '${_simplePrefix}recalculateIfrTime',
      value.recalculateIfrTime,
    );
    await prefs.setBool(
      '${_simplePrefix}overrideAirportValues',
      value.overrideAirportValues,
    );
    await prefs.setBool(
      '${_simplePrefix}overrideAircraftValues',
      value.overrideAircraftValues,
    );
    await prefs.setBool(
      '${_simplePrefix}overrideAircraftTypeValues',
      value.overrideAircraftTypeValues,
    );

    final factoringSettings = FlightFactoringSettings(
      crossCountryThresholdNm: value.crossCountryThresholdNm,
      instrumentPercent: value.instrumentPercent,
      instrumentMinimumMinutes: value.instrumentMinimumMinutes,
      instrumentSubtractMinutes: value.instrumentSubtractMinutes,
      ifrPercent: value.ifrPercent,
      ifrMinimumMinutes: value.ifrMinimumMinutes,
      ifrSubtractMinutes: value.ifrSubtractMinutes,
      irp3Percent: value.irp3Percent,
      irp3SubtractMinutes: value.irp3SubtractMinutes,
      irp4Percent: value.irp4Percent,
      irp4SubtractMinutes: value.irp4SubtractMinutes,
    );
    await prefs.setString(
      flightFactoringSettingsKey,
      jsonEncode(factoringSettings.toJson()),
    );
  }

  static Future<SouthwestImportOptions> loadSouthwest({
    CrewPosition fallbackPosition = CrewPosition.sic,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return SouthwestImportOptions(
      defaultSelfPosition:
          _parseCrewPosition(
            prefs.getString('${_swPrefix}defaultSelfPosition'),
          ) ??
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

CrewPosition? _parseCrewPosition(String? raw) {
  if (raw == null) return null;
  for (final value in CrewPosition.values) {
    if (value.name == raw && value != CrewPosition.unknown) return value;
  }
  return null;
}
