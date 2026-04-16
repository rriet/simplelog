// ignore_for_file: public_member_api_docs, document_ignores
// This file mostly defines enum values and plain import DTOs used by the UI.

import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/simplelog_import_result.dart';

/// Semantic target selected for a LogTen source column mapping.
enum LogTenFieldAssociation {
  ignore,
  flightType,
  date,
  flightNumber,
  fromAirport,
  toAirport,
  crewPic,
  crewSic,
  crewRelief,
  crewEngineer,
  crewInstructor,
  crewStudent,
  crewObserver,
  crewCabinCrew,
  crewCommander,
  crewOther,
  actualDepartureTime,
  actualArrivalTime,
  totalTime,
  picTime,
  sicTime,
  nightTime,
  crossCountryTime,
  dualReceivedTime,
  dualGivenTime,
  simulatorTime,
  soloTime,
  p1usTime,
  multiPilotTime,
  customTime1,
  customTime2,
  customTime3,
  customTime4,
  dayLandings,
  dayTakeoffs,
  nightLandings,
  nightTakeoffs,
  waterLandings,
  waterTakeoffs,
  landingTime,
  takeoffTime,
  remarks,
  distance,
  registration,
  mtow,
  aircraftNotes,
  aircraftTypeCode,
  aircraftTypeManufacturer,
  aircraftTypeModel,
  aircraftTypeEngineType,
  aircraftTypeCategory,
  aircraftComplex,
  aircraftEfis,
  aircraftHighPerformance,
}

extension LogTenFieldAssociationLabel on LogTenFieldAssociation {
  /// User-facing label shown in the mapping dropdown.
  String get label {
    return switch (this) {
      LogTenFieldAssociation.ignore => 'Ignore',
      LogTenFieldAssociation.flightType => 'Flight Type',
      LogTenFieldAssociation.date => 'Date',
      LogTenFieldAssociation.flightNumber => 'Flight Number -> Notes',
      LogTenFieldAssociation.fromAirport => 'From Airport',
      LogTenFieldAssociation.toAirport => 'To Airport',
      LogTenFieldAssociation.crewPic => 'PIC Crew',
      LogTenFieldAssociation.crewSic => 'SIC Crew',
      LogTenFieldAssociation.crewRelief => 'Relief Crew',
      LogTenFieldAssociation.crewEngineer => 'Engineer Crew',
      LogTenFieldAssociation.crewInstructor => 'Instructor Crew',
      LogTenFieldAssociation.crewStudent => 'Student Crew',
      LogTenFieldAssociation.crewObserver => 'Observer Crew',
      LogTenFieldAssociation.crewCabinCrew => 'Cabin Crew',
      LogTenFieldAssociation.crewCommander => 'Commander Crew',
      LogTenFieldAssociation.crewOther => 'Other Crew',
      LogTenFieldAssociation.actualDepartureTime => 'Actual Departure Time',
      LogTenFieldAssociation.actualArrivalTime => 'Actual Arrival Time',
      LogTenFieldAssociation.totalTime => 'Total Time',
      LogTenFieldAssociation.picTime => 'PIC Time',
      LogTenFieldAssociation.sicTime => 'SIC Time',
      LogTenFieldAssociation.nightTime => 'Night Time',
      LogTenFieldAssociation.crossCountryTime => 'Cross-country Time',
      LogTenFieldAssociation.dualReceivedTime => 'Dual Received Time',
      LogTenFieldAssociation.dualGivenTime => 'Dual Given Time',
      LogTenFieldAssociation.simulatorTime => 'Simulator Time',
      LogTenFieldAssociation.soloTime => 'Solo Time',
      LogTenFieldAssociation.p1usTime => 'PICUS/P1US Time',
      LogTenFieldAssociation.multiPilotTime => 'Multi-pilot Time',
      LogTenFieldAssociation.customTime1 => 'Custom Time 1',
      LogTenFieldAssociation.customTime2 => 'Custom Time 2',
      LogTenFieldAssociation.customTime3 => 'Custom Time 3',
      LogTenFieldAssociation.customTime4 => 'Custom Time 4',
      LogTenFieldAssociation.dayLandings => 'Day Landings',
      LogTenFieldAssociation.dayTakeoffs => 'Day Takeoffs',
      LogTenFieldAssociation.nightLandings => 'Night Landings',
      LogTenFieldAssociation.nightTakeoffs => 'Night Takeoffs',
      LogTenFieldAssociation.waterLandings => 'Water Landings',
      LogTenFieldAssociation.waterTakeoffs => 'Water Takeoffs',
      LogTenFieldAssociation.landingTime => 'Landing Time',
      LogTenFieldAssociation.takeoffTime => 'Takeoff Time',
      LogTenFieldAssociation.remarks => 'Remarks',
      LogTenFieldAssociation.distance => 'Distance NM',
      LogTenFieldAssociation.registration => 'Aircraft Registration',
      LogTenFieldAssociation.mtow => 'Aircraft MTOW',
      LogTenFieldAssociation.aircraftNotes => 'Aircraft Notes',
      LogTenFieldAssociation.aircraftTypeCode => 'Aircraft Type Code',
      LogTenFieldAssociation.aircraftTypeManufacturer =>
        'Aircraft Manufacturer',
      LogTenFieldAssociation.aircraftTypeModel => 'Aircraft Type Model',
      LogTenFieldAssociation.aircraftTypeEngineType => 'Engine Type',
      LogTenFieldAssociation.aircraftTypeCategory => 'Aircraft Category',
      LogTenFieldAssociation.aircraftComplex => 'Aircraft Complex',
      LogTenFieldAssociation.aircraftEfis => 'Aircraft EFIS',
      LogTenFieldAssociation.aircraftHighPerformance =>
        'Aircraft High Performance',
    };
  }
}

/// Fixed-offset timezone option used by the LogTen importer.
class LogTenTimezoneOption {
  /// Creates a timezone option.
  const LogTenTimezoneOption({
    required this.label,
    required this.offsetMinutes,
  });

  /// Display label shown in the UI.
  final String label;

  /// Minutes east of UTC.
  final int offsetMinutes;
}

/// Import options selected before processing a LogTen export.
class LogTenImportOptions {
  /// Creates import options.
  const LogTenImportOptions({
    required this.assignments,
    this.timezoneOffsetMinutes = 0,
    this.valueOverrides = const {},
    this.ignoredLines = const {},
  });

  /// Source-column to semantic-target assignments.
  final Map<String, LogTenFieldAssociation> assignments;

  /// Offset minutes applied to date/time values before storing UTC.
  final int timezoneOffsetMinutes;

  /// Manual per-line field fixes collected during validation review.
  final Map<int, Map<LogTenFieldAssociation, String>> valueOverrides;

  /// Source lines explicitly ignored by the user.
  final Set<int> ignoredLines;

  /// Returns a copy with selected values replaced.
  LogTenImportOptions copyWith({
    Map<String, LogTenFieldAssociation>? assignments,
    int? timezoneOffsetMinutes,
    Map<int, Map<LogTenFieldAssociation, String>>? valueOverrides,
    Set<int>? ignoredLines,
  }) {
    return LogTenImportOptions(
      assignments: assignments ?? this.assignments,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      valueOverrides: valueOverrides ?? this.valueOverrides,
      ignoredLines: ignoredLines ?? this.ignoredLines,
    );
  }
}

/// Builds the default LogTen column associations for a detected file.
Map<String, LogTenFieldAssociation> buildDefaultLogTenAssignments(
  List<String> columns,
) {
  final result = <String, LogTenFieldAssociation>{};
  for (final column in columns) {
    result[column] = switch (column) {
      'flight_type' => LogTenFieldAssociation.flightType,
      'flight_flightDate' => LogTenFieldAssociation.date,
      'flight_flightNumber' => LogTenFieldAssociation.flightNumber,
      'flight_from' => LogTenFieldAssociation.fromAirport,
      'flight_to' => LogTenFieldAssociation.toAirport,
      'flight_selectedCrewPIC' => LogTenFieldAssociation.crewPic,
      'flight_selectedCrewSIC' => LogTenFieldAssociation.crewSic,
      'flight_selectedCrewRelief' => LogTenFieldAssociation.crewRelief,
      'flight_selectedCrewRelief2' => LogTenFieldAssociation.crewRelief,
      'flight_selectedCrewRelief3' => LogTenFieldAssociation.crewRelief,
      'flight_selectedCrewRelief4' => LogTenFieldAssociation.crewRelief,
      'flight_selectedCrewFlightEngineer' =>
        LogTenFieldAssociation.crewEngineer,
      'flight_selectedCrewInstructor' => LogTenFieldAssociation.crewInstructor,
      'flight_selectedCrewStudent' => LogTenFieldAssociation.crewStudent,
      'flight_selectedCrewObserver' => LogTenFieldAssociation.crewObserver,
      'flight_selectedCrewObserver2' => LogTenFieldAssociation.crewObserver,
      'flight_selectedCrewPurser' => LogTenFieldAssociation.crewCabinCrew,
      'flight_selectedCrewFlightAttendant' =>
        LogTenFieldAssociation.crewCabinCrew,
      'flight_selectedCrewFlightAttendant2' =>
        LogTenFieldAssociation.crewCabinCrew,
      'flight_selectedCrewFlightAttendant3' =>
        LogTenFieldAssociation.crewCabinCrew,
      'flight_selectedCrewFlightAttendant4' =>
        LogTenFieldAssociation.crewCabinCrew,
      'flight_selectedCrewCommander' => LogTenFieldAssociation.crewCommander,
      'flight_selectedCrewCustom1' => LogTenFieldAssociation.crewOther,
      'flight_selectedCrewCustom2' => LogTenFieldAssociation.crewOther,
      'flight_selectedCrewCustom3' => LogTenFieldAssociation.crewOther,
      'flight_selectedCrewCustom4' => LogTenFieldAssociation.crewOther,
      'flight_selectedCrewCustom5' => LogTenFieldAssociation.crewOther,
      'flight_actualDepartureTime' =>
        LogTenFieldAssociation.actualDepartureTime,
      'flight_actualArrivalTime' => LogTenFieldAssociation.actualArrivalTime,
      'flight_totalTime' => LogTenFieldAssociation.totalTime,
      'flight_pic' => LogTenFieldAssociation.picTime,
      'flight_sic' => LogTenFieldAssociation.sicTime,
      'flight_night' => LogTenFieldAssociation.nightTime,
      'flight_crossCountry' => LogTenFieldAssociation.crossCountryTime,
      'flight_dualReceived' => LogTenFieldAssociation.dualReceivedTime,
      'flight_dualGiven' => LogTenFieldAssociation.dualGivenTime,
      'flight_simulator' => LogTenFieldAssociation.simulatorTime,
      'flight_solo' => LogTenFieldAssociation.soloTime,
      'flight_p1us' => LogTenFieldAssociation.p1usTime,
      'flight_multiPilot' => LogTenFieldAssociation.multiPilotTime,
      'flight_customTime1' => LogTenFieldAssociation.customTime1,
      'flight_customTime2' => LogTenFieldAssociation.customTime2,
      'flight_customTime3' => LogTenFieldAssociation.customTime3,
      'flight_customTime4' => LogTenFieldAssociation.customTime4,
      'flight_dayLandings' => LogTenFieldAssociation.dayLandings,
      'flight_dayTakeoffs' => LogTenFieldAssociation.dayTakeoffs,
      'flight_nightLandings' => LogTenFieldAssociation.nightLandings,
      'flight_nightTakeoffs' => LogTenFieldAssociation.nightTakeoffs,
      'flight_waterLandings' => LogTenFieldAssociation.waterLandings,
      'flight_waterTakeoffs' => LogTenFieldAssociation.waterTakeoffs,
      'flight_landingTime' => LogTenFieldAssociation.landingTime,
      'flight_takeoffTime' => LogTenFieldAssociation.takeoffTime,
      'flight_remarks' => LogTenFieldAssociation.remarks,
      'flight_distance' => LogTenFieldAssociation.distance,
      'aircraft_aircraftID' => LogTenFieldAssociation.registration,
      'aircraft_weight' => LogTenFieldAssociation.mtow,
      'aircraft_notes' => LogTenFieldAssociation.aircraftNotes,
      'aircraft_complex' => LogTenFieldAssociation.aircraftComplex,
      'aircraft_efis' => LogTenFieldAssociation.aircraftEfis,
      'aircraft_highPerformance' =>
        LogTenFieldAssociation.aircraftHighPerformance,
      'aircraftType_type' => LogTenFieldAssociation.aircraftTypeCode,
      'aircraftType_make' => LogTenFieldAssociation.aircraftTypeManufacturer,
      'aircraftType_model' => LogTenFieldAssociation.aircraftTypeModel,
      'aircraftType_selectedEngineType' =>
        LogTenFieldAssociation.aircraftTypeEngineType,
      'aircraftType_selectedCategory' =>
        LogTenFieldAssociation.aircraftTypeCategory,
      _ => LogTenFieldAssociation.ignore,
    };
  }
  return result;
}

/// Row-level parser issue collected during LogTen import.
class LogTenImportIssue {
  /// Creates a row issue.
  const LogTenImportIssue({
    required this.lineNumber,
    required this.association,
    required this.currentValue,
    required this.reason,
    this.canMarkAsSimulator = false,
  });

  /// Source line number in the TSV file.
  final int lineNumber;

  /// Semantic field currently failing validation.
  final LogTenFieldAssociation association;

  /// Current source value for the invalid field.
  final String currentValue;

  /// Human-readable failure reason.
  final String reason;

  /// Whether this line can be switched to simulator mode during review.
  final bool canMarkAsSimulator;
}

/// Parsed LogTen import payload plus collected row issues.
class LogTenParseResult {
  /// Creates a parse result.
  const LogTenParseResult({
    required this.batch,
    required this.issues,
  });

  /// Normalized records ready for persistence.
  final NormalizedImportBatch batch;

  /// Row issues collected while parsing.
  final List<LogTenImportIssue> issues;
}

/// Final LogTen import result shown to the user.
class LogTenImportResult {
  /// Creates a final LogTen import result.
  const LogTenImportResult({
    required this.summary,
    required this.issues,
  });

  /// Aggregate import counters.
  final SimpleLogImportResult summary;

  /// Row issues collected while parsing.
  final List<LogTenImportIssue> issues;
}
