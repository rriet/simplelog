import 'package:simplelog/core/flight/pilot_function_logic.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/simplelog_csv_support.dart';
import 'package:simplelog/data/import/wader_import_models.dart';
import 'package:simplelog/data/import/wader_import_options.dart';

/// Parses Wader CSV exports into normalized import records.
class WaderLogbookCsvSourceParser {
  /// Creates a parser.
  const WaderLogbookCsvSourceParser();

  /// Parses Wader CSV content into a normalized import batch.
  NormalizedImportBatch parse(
    String content, {
    WaderImportOptions options = const WaderImportOptions(),
    WaderImportReviewOptions reviewOptions = const WaderImportReviewOptions(),
  }) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    if (rows.isEmpty) {
      return const NormalizedImportBatch(
        totalRows: 0,
        records: <NormalizedImportRecord>[],
        entityOptions: ImportedEntityOptions(
          overrideAirportValues: false,
          overrideAircraftValues: false,
          overrideAircraftTypeValues: false,
          overrideCrewValues: false,
        ),
      );
    }

    final header = rows.first;
    final index = <String, int>{
      for (var i = 0; i < header.length; i += 1)
        header[i].trim().toLowerCase(): i,
    };
    int idx(String name) => index[name] ?? -1;
    String read(List<String> row, int column) {
      if (column < 0 || column >= row.length) return '';
      return row[column].trim();
    }

    final idxIsSimulator = idx('issimulator');
    final idxFlightDate = idx('flightdate');
    final idxStartTime = idx('starttime');
    final idxParkingTime = idx('parkingtime');
    final idxFlightNumber = idx('flightnumber');
    final idxDepAirport = idx('depairport');
    final idxArrAirport = idx('arrairport');
    final idxTail = idx('aircrafttailnumber');
    final idxAircraftType = idx('aircrafttype');
    final idxFunction = idx('function');
    final idxPilot1 = idx('pilotname1');
    final idxPilot2 = idx('pilotname2');
    final idxPilot3 = idx('pilotname3');
    final idxPilot4 = idx('pilotname4');
    final idxTotalTime = idx('totaltime');
    final idxPicTime = idx('pictime');
    final idxSicTime = idx('sictime');
    final idxDualTime = idx('dualtime');
    final idxPicusTime = idx('picustime');
    final idxInstructorTime = idx('instructortime');
    final idxIfrTime = idx('ifrtime');
    final idxNightTime = idx('nighttime');
    final idxXcTime = idx('crosscountrytime');
    final idxDayTko = idx('daytakeoffs');
    final idxNightTko = idx('nighttakeoffs');
    final idxDayLdg = idx('daylandings');
    final idxNightLdg = idx('nightlandings');
    final idxApproachType = idx('approachtype');
    final idxRemarks = idx('remarks');
    final idxMultiEngine = idx('multiengine');
    final idxMultiPilot = idx('multipilot');
    final idxSimTrainee = idx('simtraineetime');
    final idxSimTrainer = idx('simtrainertime');

    final records = <NormalizedImportRecord>[];
    var skipped = 0;
    var errors = 0;
    var progressOrdinal = 0;

    for (var i = 1; i < rows.length; i += 1) {
      progressOrdinal += 1;
      final lineNumber = i + 1;
      if (reviewOptions.ignoredLines.contains(lineNumber) ||
          reviewOptions.totalTimeResolutions[lineNumber] ==
              WaderTotalTimeResolution.ignoreLine) {
        skipped += 1;
        continue;
      }
      final row = _resolvedRow(
        row: rows[i],
        lineNumber: lineNumber,
        read: read,
        reviewOptions: reviewOptions,
        idxIsSimulator: idxIsSimulator,
        idxFlightDate: idxFlightDate,
        idxStartTime: idxStartTime,
        idxParkingTime: idxParkingTime,
        idxFlightNumber: idxFlightNumber,
        idxDepAirport: idxDepAirport,
        idxArrAirport: idxArrAirport,
        idxTail: idxTail,
        idxAircraftType: idxAircraftType,
        idxFunction: idxFunction,
        idxPilot1: idxPilot1,
        idxPilot2: idxPilot2,
        idxPilot3: idxPilot3,
        idxPilot4: idxPilot4,
        idxTotalTime: idxTotalTime,
        idxPicTime: idxPicTime,
        idxSicTime: idxSicTime,
        idxDualTime: idxDualTime,
        idxPicusTime: idxPicusTime,
        idxInstructorTime: idxInstructorTime,
        idxIfrTime: idxIfrTime,
        idxNightTime: idxNightTime,
        idxXcTime: idxXcTime,
        idxDayTko: idxDayTko,
        idxNightTko: idxNightTko,
        idxDayLdg: idxDayLdg,
        idxNightLdg: idxNightLdg,
        idxApproachType: idxApproachType,
        idxRemarks: idxRemarks,
        idxMultiEngine: idxMultiEngine,
        idxMultiPilot: idxMultiPilot,
        idxSimTrainee: idxSimTrainee,
        idxSimTrainer: idxSimTrainer,
      );
      final issues = _validateResolvedRow(
        row,
        options: options,
        reviewOptions: reviewOptions,
      );
      if (issues.isNotEmpty) {
        skipped += 1;
        continue;
      }
      try {
        records.add(
          _toNormalizedRecord(
            row,
            progressOrdinal,
            options: options,
            reviewOptions: reviewOptions,
          ),
        );
      } on FormatException {
        errors += 1;
      }
    }

    return NormalizedImportBatch(
      totalRows: rows.length - 1,
      records: records,
      entityOptions: const ImportedEntityOptions(
        overrideAirportValues: false,
        overrideAircraftValues: false,
        overrideAircraftTypeValues: false,
        overrideCrewValues: false,
      ),
      skippedRows: skipped,
      errorRows: errors,
    );
  }

  /// Validates Wader CSV and returns user-resolvable issues.
  List<WaderImportIssue> validate(
    String content, {
    WaderImportOptions options = const WaderImportOptions(),
    WaderImportReviewOptions reviewOptions = const WaderImportReviewOptions(),
    Set<String> existingAirportIcaoCodes = const <String>{},
  }) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    if (rows.isEmpty) {
      return const <WaderImportIssue>[];
    }
    final header = rows.first;
    final index = <String, int>{
      for (var i = 0; i < header.length; i += 1)
        header[i].trim().toLowerCase(): i,
    };
    int idx(String name) => index[name] ?? -1;
    String read(List<String> row, int column) {
      if (column < 0 || column >= row.length) return '';
      return row[column].trim();
    }

    final idxIsSimulator = idx('issimulator');
    final idxFlightDate = idx('flightdate');
    final idxStartTime = idx('starttime');
    final idxParkingTime = idx('parkingtime');
    final idxFlightNumber = idx('flightnumber');
    final idxDepAirport = idx('depairport');
    final idxArrAirport = idx('arrairport');
    final idxTail = idx('aircrafttailnumber');
    final idxAircraftType = idx('aircrafttype');
    final idxFunction = idx('function');
    final idxPilot1 = idx('pilotname1');
    final idxPilot2 = idx('pilotname2');
    final idxPilot3 = idx('pilotname3');
    final idxPilot4 = idx('pilotname4');
    final idxTotalTime = idx('totaltime');
    final idxPicTime = idx('pictime');
    final idxSicTime = idx('sictime');
    final idxDualTime = idx('dualtime');
    final idxPicusTime = idx('picustime');
    final idxInstructorTime = idx('instructortime');
    final idxIfrTime = idx('ifrtime');
    final idxNightTime = idx('nighttime');
    final idxXcTime = idx('crosscountrytime');
    final idxDayTko = idx('daytakeoffs');
    final idxNightTko = idx('nighttakeoffs');
    final idxDayLdg = idx('daylandings');
    final idxNightLdg = idx('nightlandings');
    final idxApproachType = idx('approachtype');
    final idxRemarks = idx('remarks');
    final idxMultiEngine = idx('multiengine');
    final idxMultiPilot = idx('multipilot');
    final idxSimTrainee = idx('simtraineetime');
    final idxSimTrainer = idx('simtrainertime');

    final issues = <WaderImportIssue>[];
    for (var i = 1; i < rows.length; i += 1) {
      final lineNumber = i + 1;
      if (reviewOptions.ignoredLines.contains(lineNumber) ||
          reviewOptions.totalTimeResolutions[lineNumber] ==
              WaderTotalTimeResolution.ignoreLine) {
        continue;
      }
      final row = _resolvedRow(
        row: rows[i],
        lineNumber: lineNumber,
        read: read,
        reviewOptions: reviewOptions,
        idxIsSimulator: idxIsSimulator,
        idxFlightDate: idxFlightDate,
        idxStartTime: idxStartTime,
        idxParkingTime: idxParkingTime,
        idxFlightNumber: idxFlightNumber,
        idxDepAirport: idxDepAirport,
        idxArrAirport: idxArrAirport,
        idxTail: idxTail,
        idxAircraftType: idxAircraftType,
        idxFunction: idxFunction,
        idxPilot1: idxPilot1,
        idxPilot2: idxPilot2,
        idxPilot3: idxPilot3,
        idxPilot4: idxPilot4,
        idxTotalTime: idxTotalTime,
        idxPicTime: idxPicTime,
        idxSicTime: idxSicTime,
        idxDualTime: idxDualTime,
        idxPicusTime: idxPicusTime,
        idxInstructorTime: idxInstructorTime,
        idxIfrTime: idxIfrTime,
        idxNightTime: idxNightTime,
        idxXcTime: idxXcTime,
        idxDayTko: idxDayTko,
        idxNightTko: idxNightTko,
        idxDayLdg: idxDayLdg,
        idxNightLdg: idxNightLdg,
        idxApproachType: idxApproachType,
        idxRemarks: idxRemarks,
        idxMultiEngine: idxMultiEngine,
        idxMultiPilot: idxMultiPilot,
        idxSimTrainee: idxSimTrainee,
        idxSimTrainer: idxSimTrainer,
      );
      issues.addAll(
        _validateResolvedRow(
          row,
          options: options,
          reviewOptions: reviewOptions,
          existingAirportIcaoCodes: existingAirportIcaoCodes,
        ),
      );
    }
    return issues;
  }
}

class _WaderResolvedRow {
  const _WaderResolvedRow({
    required this.lineNumber,
    required this.isSimulator,
    required this.dateText,
    required this.startTimeText,
    required this.parkingTimeText,
    required this.flightNumber,
    required this.depCode,
    required this.arrCode,
    required this.registration,
    required this.typeCode,
    required this.functionRaw,
    required this.pilot1,
    required this.pilot2,
    required this.pilot3,
    required this.pilot4,
    required this.totalTimeText,
    required this.picTimeText,
    required this.sicTimeText,
    required this.dualTimeText,
    required this.picusTimeText,
    required this.instructorTimeText,
    required this.ifrTimeText,
    required this.nightTimeText,
    required this.xcTimeText,
    required this.dayTakeoffsText,
    required this.nightTakeoffsText,
    required this.dayLandingsText,
    required this.nightLandingsText,
    required this.approachType,
    required this.remarks,
    required this.multiEngine,
    required this.multiPilot,
    required this.simTraineeTimeText,
    required this.simTrainerTimeText,
  });

  final int lineNumber;
  final bool isSimulator;
  final String dateText;
  final String startTimeText;
  final String parkingTimeText;
  final String flightNumber;
  final String depCode;
  final String arrCode;
  final String registration;
  final String typeCode;
  final String functionRaw;
  final String pilot1;
  final String pilot2;
  final String pilot3;
  final String pilot4;
  final String totalTimeText;
  final String picTimeText;
  final String sicTimeText;
  final String dualTimeText;
  final String picusTimeText;
  final String instructorTimeText;
  final String ifrTimeText;
  final String nightTimeText;
  final String xcTimeText;
  final String dayTakeoffsText;
  final String nightTakeoffsText;
  final String dayLandingsText;
  final String nightLandingsText;
  final String approachType;
  final String remarks;
  final bool multiEngine;
  final bool multiPilot;
  final String simTraineeTimeText;
  final String simTrainerTimeText;
}

_WaderResolvedRow _resolvedRow({
  required List<String> row,
  required int lineNumber,
  required String Function(List<String> row, int column) read,
  required WaderImportReviewOptions reviewOptions,
  required int idxIsSimulator,
  required int idxFlightDate,
  required int idxStartTime,
  required int idxParkingTime,
  required int idxFlightNumber,
  required int idxDepAirport,
  required int idxArrAirport,
  required int idxTail,
  required int idxAircraftType,
  required int idxFunction,
  required int idxPilot1,
  required int idxPilot2,
  required int idxPilot3,
  required int idxPilot4,
  required int idxTotalTime,
  required int idxPicTime,
  required int idxSicTime,
  required int idxDualTime,
  required int idxPicusTime,
  required int idxInstructorTime,
  required int idxIfrTime,
  required int idxNightTime,
  required int idxXcTime,
  required int idxDayTko,
  required int idxNightTko,
  required int idxDayLdg,
  required int idxNightLdg,
  required int idxApproachType,
  required int idxRemarks,
  required int idxMultiEngine,
  required int idxMultiPilot,
  required int idxSimTrainee,
  required int idxSimTrainer,
}) {
  String resolved(WaderFieldAssociation association, String originalValue) {
    final override = reviewOptions.valueOverrides[lineNumber]?[association]
        ?.trim();
    return override ?? originalValue.trim();
  }

  return _WaderResolvedRow(
    lineNumber: lineNumber,
    isSimulator: _parseBool(read(row, idxIsSimulator)),
    dateText: resolved(WaderFieldAssociation.date, read(row, idxFlightDate)),
    startTimeText: resolved(
      WaderFieldAssociation.startTime,
      read(row, idxStartTime),
    ),
    parkingTimeText: resolved(
      WaderFieldAssociation.parkingTime,
      read(row, idxParkingTime),
    ),
    flightNumber: read(row, idxFlightNumber),
    depCode: _normalizedCode(
      resolved(
        WaderFieldAssociation.departureAirport,
        _normalizedCode(read(row, idxDepAirport)),
      ),
    ),
    arrCode: _normalizedCode(
      resolved(
        WaderFieldAssociation.arrivalAirport,
        _normalizedCode(read(row, idxArrAirport)),
      ),
    ),
    registration: _normalizedCode(
      resolved(
        WaderFieldAssociation.aircraftTail,
        _normalizedCode(read(row, idxTail)),
      ),
    ),
    typeCode: _normalizedCode(
      resolved(
        WaderFieldAssociation.aircraftType,
        _normalizedCode(read(row, idxAircraftType)),
      ),
    ),
    functionRaw: read(row, idxFunction),
    pilot1: read(row, idxPilot1),
    pilot2: read(row, idxPilot2),
    pilot3: read(row, idxPilot3),
    pilot4: read(row, idxPilot4),
    totalTimeText: resolved(
      WaderFieldAssociation.totalTime,
      read(row, idxTotalTime),
    ),
    picTimeText: read(row, idxPicTime),
    sicTimeText: read(row, idxSicTime),
    dualTimeText: read(row, idxDualTime),
    picusTimeText: read(row, idxPicusTime),
    instructorTimeText: read(row, idxInstructorTime),
    ifrTimeText: read(row, idxIfrTime),
    nightTimeText: read(row, idxNightTime),
    xcTimeText: read(row, idxXcTime),
    dayTakeoffsText: read(row, idxDayTko),
    nightTakeoffsText: read(row, idxNightTko),
    dayLandingsText: read(row, idxDayLdg),
    nightLandingsText: read(row, idxNightLdg),
    approachType: read(row, idxApproachType),
    remarks: read(row, idxRemarks),
    multiEngine: _parseBool(read(row, idxMultiEngine)),
    multiPilot: _parseBool(read(row, idxMultiPilot)),
    simTraineeTimeText: resolved(
      WaderFieldAssociation.simTraineeTime,
      read(row, idxSimTrainee),
    ),
    simTrainerTimeText: resolved(
      WaderFieldAssociation.simTrainerTime,
      read(row, idxSimTrainer),
    ),
  );
}

List<WaderImportIssue> _validateResolvedRow(
  _WaderResolvedRow row, {
  required WaderImportOptions options,
  required WaderImportReviewOptions reviewOptions,
  Set<String> existingAirportIcaoCodes = const <String>{},
}) {
  final issues = <WaderImportIssue>[];
  final baseDate = _tryParseDate(row.dateText);
  if (baseDate == null) {
    issues.add(
      WaderImportIssue(
        lineNumber: row.lineNumber,
        association: WaderFieldAssociation.date,
        currentValue: row.dateText,
        reason: row.dateText.isEmpty ? 'Date is required.' : 'Invalid date.',
      ),
    );
    return issues;
  }

  final startDateTime = _tryParseDateTime(baseDate, row.startTimeText);
  if (startDateTime == null) {
    issues.add(
      WaderImportIssue(
        lineNumber: row.lineNumber,
        association: WaderFieldAssociation.startTime,
        currentValue: row.startTimeText,
        reason: 'Invalid start time.',
      ),
    );
  }

  if (row.typeCode.isEmpty) {
    issues.add(
      WaderImportIssue(
        lineNumber: row.lineNumber,
        association: WaderFieldAssociation.aircraftType,
        currentValue: row.typeCode,
        reason: 'Aircraft type is required.',
      ),
    );
  }
  if (row.registration.isEmpty) {
    issues.add(
      WaderImportIssue(
        lineNumber: row.lineNumber,
        association: WaderFieldAssociation.aircraftTail,
        currentValue: row.registration,
        reason: 'Aircraft tail number is required.',
      ),
    );
  }

  if (row.isSimulator) {
    final durationMinutes = _firstPositive(<int>[
      _parseDurationMinutes(row.simTraineeTimeText),
      _parseDurationMinutes(row.simTrainerTimeText),
      _parseDurationMinutes(row.totalTimeText),
    ]);
    if (durationMinutes <= 0) {
      issues.add(
        WaderImportIssue(
          lineNumber: row.lineNumber,
          association: WaderFieldAssociation.totalTime,
          currentValue: row.totalTimeText,
          reason: 'Simulator duration is required.',
        ),
      );
    }
    return issues;
  }

  if (!_isAirportCode(row.depCode)) {
    final code = row.depCode.trim().toUpperCase();
    issues.add(
      WaderImportIssue(
        lineNumber: row.lineNumber,
        association: WaderFieldAssociation.departureAirport,
        currentValue: row.depCode,
        reason: code.isEmpty
            ? 'Departure airport is missing.'
            : 'Airport ICAO code $code is not valid.',
      ),
    );
  } else if (existingAirportIcaoCodes.isNotEmpty &&
      !existingAirportIcaoCodes.contains(row.depCode.trim().toUpperCase())) {
    final code = row.depCode.trim().toUpperCase();
    issues.add(
      WaderImportIssue(
        lineNumber: row.lineNumber,
        association: WaderFieldAssociation.departureAirport,
        currentValue: row.depCode,
        reason: 'Airport $code does not exist in the database.',
      ),
    );
  }
  if (!_isAirportCode(row.arrCode)) {
    final code = row.arrCode.trim().toUpperCase();
    issues.add(
      WaderImportIssue(
        lineNumber: row.lineNumber,
        association: WaderFieldAssociation.arrivalAirport,
        currentValue: row.arrCode,
        reason: code.isEmpty
            ? 'Arrival airport is missing.'
            : 'Airport ICAO code $code is not valid.',
      ),
    );
  } else if (existingAirportIcaoCodes.isNotEmpty &&
      !existingAirportIcaoCodes.contains(row.arrCode.trim().toUpperCase())) {
    final code = row.arrCode.trim().toUpperCase();
    issues.add(
      WaderImportIssue(
        lineNumber: row.lineNumber,
        association: WaderFieldAssociation.arrivalAirport,
        currentValue: row.arrCode,
        reason: 'Airport $code does not exist in the database.',
      ),
    );
  }
  if (row.parkingTimeText.isNotEmpty &&
      _tryParseDateTime(baseDate, row.parkingTimeText) == null) {
    issues.add(
      WaderImportIssue(
        lineNumber: row.lineNumber,
        association: WaderFieldAssociation.parkingTime,
        currentValue: row.parkingTimeText,
        reason: 'Invalid parking time.',
      ),
    );
  }
  final totalMinutes = _parseDurationMinutes(row.totalTimeText);
  final totalResolution =
      reviewOptions.totalTimeResolutions[row.lineNumber] ??
      WaderTotalTimeResolution.none;
  if (!options.recalculateTotalTime &&
      totalResolution != WaderTotalTimeResolution.calculateFromChocks &&
      row.parkingTimeText.isEmpty &&
      totalMinutes <= 0) {
    issues.add(
      WaderImportIssue(
        lineNumber: row.lineNumber,
        association: WaderFieldAssociation.totalTime,
        currentValue: row.totalTimeText,
        reason: 'Total time is required when parking time is empty.',
      ),
    );
  }
  final hasTotalTimeIssue = issues.any(
    (issue) => issue.association == WaderFieldAssociation.totalTime,
  );
  if (startDateTime != null) {
    final arrivalDateTime = _tryResolveArrivalDateTime(
      baseDate: baseDate,
      departureDateTime: startDateTime,
      parkingTimeText: row.parkingTimeText,
      totalMinutes: totalMinutes,
    );
    if (!hasTotalTimeIssue && arrivalDateTime != null) {
      final computedMinutes = switch (totalResolution) {
        WaderTotalTimeResolution.calculateFromChocks =>
          arrivalDateTime.difference(startDateTime).inMinutes,
        WaderTotalTimeResolution.useBlockValue => totalMinutes,
        _ =>
          options.recalculateTotalTime
              ? arrivalDateTime.difference(startDateTime).inMinutes
              : totalMinutes,
      };
      if (computedMinutes <= 0) {
        issues.add(
          WaderImportIssue(
            lineNumber: row.lineNumber,
            association: WaderFieldAssociation.totalTime,
            currentValue: row.totalTimeText,
            reason: 'Total time must be greater than zero.',
          ),
        );
      }
    }
  }
  return issues;
}

NormalizedImportRecord _toNormalizedRecord(
  _WaderResolvedRow row,
  int ordinal, {
  required WaderImportOptions options,
  required WaderImportReviewOptions reviewOptions,
}) {
  final baseDate = _parseDate(row.dateText);
  final startDateTime = _parseDateTime(baseDate, row.startTimeText);
  final aircraftType = ImportedAircraftTypeDraft(
    code: row.typeCode,
    family: row.typeCode,
    longName: row.typeCode,
    manufacturer: '',
    category: AircraftCategory.landplane,
    engineType: EngineType.jet,
    mtow: 0,
    engineCount: row.multiEngine ? 2 : 1,
    multiPilot: row.multiPilot,
    complex: row.multiPilot,
    efis: row.multiPilot,
    highPerformance: row.multiPilot,
  );
  final aircraft = ImportedAircraftDraft(
    registration: row.registration,
    mtow: null,
    isSimulator: row.isSimulator,
  );
  final remarks = _joinedNonEmpty([row.flightNumber, row.remarks]);
  final crewAssignments = _crewAssignmentsForRow(
    functionRaw: row.functionRaw,
    crewNames: _pilotNames(row.pilot1, row.pilot2, row.pilot3, row.pilot4),
  );

  if (row.isSimulator) {
    final durationMinutes = _firstPositive(<int>[
      _parseDurationMinutes(row.simTraineeTimeText),
      _parseDurationMinutes(row.simTrainerTimeText),
      _parseDurationMinutes(row.totalTimeText),
    ]);
    return NormalizedSimulatorRecord(
      progressOrdinal: ordinal,
      aircraftType: aircraftType,
      aircraft: aircraft,
      startDateTime: startDateTime,
      endDateTime: startDateTime.add(Duration(minutes: durationMinutes)),
      timeTotal: durationMinutes,
      remarks: remarks,
      notes: '',
      crewAssignments: crewAssignments,
    );
  }

  final preferredResolution =
      reviewOptions.totalTimeResolutions[row.lineNumber] ??
      WaderTotalTimeResolution.none;
  final arrivalDateTime = _resolveArrivalDateTime(
    baseDate: baseDate,
    departureDateTime: startDateTime,
    parkingTimeText: row.parkingTimeText,
    totalMinutes: _parseDurationMinutes(row.totalTimeText),
  );
  final csvTotalMinutes = _parseDurationMinutes(row.totalTimeText);
  final chocksMinutes = arrivalDateTime.difference(startDateTime).inMinutes;
  final totalMinutes = switch (preferredResolution) {
    WaderTotalTimeResolution.calculateFromChocks => chocksMinutes,
    WaderTotalTimeResolution.useBlockValue => csvTotalMinutes,
    _ => options.recalculateTotalTime ? chocksMinutes : csvTotalMinutes,
  };
  final takeoffsDay = _parseInt(row.dayTakeoffsText);
  final takeoffsNight = _parseInt(row.nightTakeoffsText);
  final landingsDay = _parseInt(row.dayLandingsText);
  final landingsNight = _parseInt(row.nightLandingsText);
  final totalTakeoffs = takeoffsDay + takeoffsNight;
  final totalLandings = landingsDay + landingsNight;

  return NormalizedFlightRecord(
    progressOrdinal: ordinal,
    departureAirport: ImportedAirportDraft(icao: row.depCode),
    arrivalAirport: ImportedAirportDraft(icao: row.arrCode),
    aircraftType: aircraftType,
    aircraft: aircraft,
    departureDateTime: startDateTime,
    arrivalDateTime: arrivalDateTime,
    timePicMinutes: _parseInt(row.picTimeText),
    timePicusMinutes: _parseInt(row.picusTimeText),
    timeSicMinutes: _parseInt(row.sicTimeText),
    timeDualMinutes: _parseInt(row.dualTimeText),
    timeInstructorMinutes: _parseInt(row.instructorTimeText),
    timeIfrMinutes: _parseInt(row.ifrTimeText),
    timeNightMinutes: _parseInt(row.nightTimeText),
    timeCrossCountryMinutes: _parseInt(row.xcTimeText),
    timeCustom1Minutes: 0,
    timeCustom2Minutes: 0,
    timeCustom3Minutes: 0,
    timeCustom4Minutes: 0,
    timeFlightMinutes: totalMinutes,
    timeBlockMinutes: totalMinutes,
    timeTotalBlockMinutes: totalMinutes,
    distanceNm: 0,
    ifrApproaches: 0,
    takeoffsDay: takeoffsDay,
    takeoffsNight: takeoffsNight,
    landingsDay: landingsDay,
    landingsNight: landingsNight,
    pilotFunction: PilotFunctionLogic.fromTakeoffLanding(
      takeoffCount: totalTakeoffs,
      landingCount: totalLandings,
    ),
    approachType: row.approachType,
    remarks: remarks,
    notes: '',
    crewAssignments: crewAssignments,
  );
}

DateTime _parseDate(String text) {
  final parts = text.split('-');
  if (parts.length != 3) {
    throw const FormatException('Invalid Wader date.');
  }
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    throw const FormatException('Invalid Wader date values.');
  }
  return DateTime.utc(year, month, day);
}

DateTime? _tryParseDate(String text) {
  try {
    return _parseDate(text);
  } on FormatException {
    return null;
  }
}

DateTime _parseDateTime(DateTime date, String hhmm) {
  if (hhmm.isEmpty) {
    return DateTime.utc(date.year, date.month, date.day);
  }
  final parts = hhmm.split(':');
  if (parts.length != 2) {
    throw const FormatException('Invalid Wader time.');
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    throw const FormatException('Invalid Wader time values.');
  }
  return DateTime.utc(date.year, date.month, date.day, hour, minute);
}

DateTime? _tryParseDateTime(DateTime date, String hhmm) {
  try {
    return _parseDateTime(date, hhmm);
  } on FormatException {
    return null;
  }
}

DateTime _resolveArrivalDateTime({
  required DateTime baseDate,
  required DateTime departureDateTime,
  required String parkingTimeText,
  required int totalMinutes,
}) {
  if (parkingTimeText.isNotEmpty) {
    var arrival = _parseDateTime(baseDate, parkingTimeText);
    if (!arrival.isAfter(departureDateTime)) {
      arrival = arrival.add(const Duration(days: 1));
    }
    return arrival;
  }
  final minutes = totalMinutes > 0 ? totalMinutes : 0;
  return departureDateTime.add(Duration(minutes: minutes));
}

DateTime? _tryResolveArrivalDateTime({
  required DateTime baseDate,
  required DateTime departureDateTime,
  required String parkingTimeText,
  required int totalMinutes,
}) {
  try {
    return _resolveArrivalDateTime(
      baseDate: baseDate,
      departureDateTime: departureDateTime,
      parkingTimeText: parkingTimeText,
      totalMinutes: totalMinutes,
    );
  } on FormatException {
    return null;
  }
}

int _parseInt(String value) => int.tryParse(value.trim()) ?? 0;

int _parseDurationMinutes(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 0;
  }
  final direct = int.tryParse(trimmed);
  if (direct != null) {
    return direct;
  }
  final parts = trimmed.split(':');
  if (parts.length != 2) {
    return 0;
  }
  final hours = int.tryParse(parts[0]);
  final minutes = int.tryParse(parts[1]);
  if (hours == null ||
      minutes == null ||
      hours < 0 ||
      minutes < 0 ||
      minutes > 59) {
    return 0;
  }
  return hours * 60 + minutes;
}

bool _parseBool(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}

int _firstPositive(List<int> values) {
  for (final value in values) {
    if (value > 0) return value;
  }
  return 0;
}

String _normalizedCode(String value) => value.trim().toUpperCase();

bool _isAirportCode(String value) {
  if (value.isEmpty || value == '-') return false;
  return RegExp(r'^[A-Z0-9]{3,4}$').hasMatch(value);
}

List<String> _pilotNames(String p1, String p2, String p3, String p4) {
  return <String>[p1, p2, p3, p4]
      .map((name) => name.trim())
      .where((name) => name.isNotEmpty)
      .toList(growable: false);
}

List<ImportedCrewAssignmentDraft> _crewAssignmentsForRow({
  required String functionRaw,
  required List<String> crewNames,
}) {
  if (crewNames.isEmpty) return const <ImportedCrewAssignmentDraft>[];
  final function = functionRaw.trim().toLowerCase();
  final position = switch (function) {
    'pic' => CrewPosition.pic,
    'sic' => CrewPosition.sic,
    'picus' => CrewPosition.picus,
    'instructor' => CrewPosition.instructor,
    'trainer' => CrewPosition.instructor,
    'trainee' => CrewPosition.trainee,
    _ => CrewPosition.sic,
  };
  final assignments = <ImportedCrewAssignmentDraft>[];
  for (final name in crewNames) {
    if (name.toUpperCase() == 'SELF') {
      assignments.add(
        ImportedCrewAssignmentDraft.self(
          position: position,
          createSelfIfMissing: true,
        ),
      );
      continue;
    }
    assignments.add(
      ImportedCrewAssignmentDraft.crew(
        position: position,
        crew: ImportedCrewDraft(name: name),
      ),
    );
  }
  return assignments;
}

String _joinedNonEmpty(List<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' | ');
}
