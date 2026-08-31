import 'package:simplelog/core/flight/flight_calculations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/import/logten_pro_import_models.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/simplelog_csv_support.dart';

/// Parses LogTen Pro tab-separated exports into normalized import records.
class LogTenProTsvSourceParser {
  /// Creates a parser.
  const LogTenProTsvSourceParser();

  /// Parses a LogTen Pro tab-separated export into a normalized batch.
  LogTenParseResult parse(
    String content, {
    required LogTenImportOptions options,
    required Map<String, Airport> existingAirportsByIcao,
    required Map<String, Airport> existingAirportsByIata,
    bool includeIgnoredLineIssues = false,
  }) {
    return _parseRows(
      _parseTsv(content),
      options: options,
      existingAirportsByIcao: existingAirportsByIcao,
      existingAirportsByIata: existingAirportsByIata,
      includeIgnoredLineIssues: includeIgnoredLineIssues,
      allowUnknownAirports: false,
    );
  }

  /// Parses a CSV export that uses the same field mapping and review flow.
  LogTenParseResult parseCsv(
    String content, {
    required LogTenImportOptions options,
    required Map<String, Airport> existingAirportsByIcao,
    required Map<String, Airport> existingAirportsByIata,
    bool includeIgnoredLineIssues = false,
  }) {
    return _parseRows(
      SimpleLogCsvSupport.parseCsv(content),
      options: options,
      existingAirportsByIcao: existingAirportsByIcao,
      existingAirportsByIata: existingAirportsByIata,
      includeIgnoredLineIssues: includeIgnoredLineIssues,
      allowUnknownAirports: false,
    );
  }

  LogTenParseResult _parseRows(
    List<List<String>> rows, {
    required LogTenImportOptions options,
    required Map<String, Airport> existingAirportsByIcao,
    required Map<String, Airport> existingAirportsByIata,
    required bool includeIgnoredLineIssues,
    required bool allowUnknownAirports,
  }) {
    if (rows.isEmpty) {
      return const LogTenParseResult(
        batch: NormalizedImportBatch(
          totalRows: 0,
          records: [],
          entityOptions: ImportedEntityOptions(
            overrideAirportValues: false,
            overrideAircraftValues: false,
            overrideAircraftTypeValues: false,
            overrideCrewValues: false,
          ),
        ),
        issues: [],
      );
    }

    final header = rows.first
        .map((value) => value.trim())
        .toList(growable: false);
    final headerIndex = <String, int>{
      for (var i = 0; i < header.length; i += 1) header[i]: i,
    };
    final plan = _LogTenMappingPlan.fromAssignments(
      assignments: options.assignments,
      header: header,
    );
    final timeFormat = _detectTimeFormat(
      rows.skip(1),
      headerIndex,
      plan,
      options,
    );

    final records = <NormalizedImportRecord>[];
    final issues = <LogTenImportIssue>[];
    var skipped = 0;
    var progressOrdinal = 0;

    for (var fileRowIndex = 1; fileRowIndex < rows.length; fileRowIndex += 1) {
      progressOrdinal += 1;
      final sourceLineNumber = fileRowIndex + 1;
      if (options.ignoredLines.contains(sourceLineNumber)) {
        skipped += 1;
        if (includeIgnoredLineIssues) {
          issues.add(
            LogTenImportIssue(
              lineNumber: sourceLineNumber,
              association: LogTenFieldAssociation.ignore,
              currentValue: '',
              reason: 'Ignored by user.',
            ),
          );
        }
        continue;
      }
      final row = _LogTenRow(
        values: rows[fileRowIndex],
        headerIndex: headerIndex,
        lineNumber: sourceLineNumber,
        plan: plan,
        options: options,
      );

      try {
        final flightType = row.firstValue(LogTenFieldAssociation.flightType);
        if (flightType.isEmpty) {
          final record = _buildFlightRecord(
            row,
            progressOrdinal: progressOrdinal,
            timeFormat: timeFormat,
            timezoneOffsetMinutes: options.timezoneOffsetMinutes,
            existingAirportsByIcao: existingAirportsByIcao,
            existingAirportsByIata: existingAirportsByIata,
            allowUnknownAirports: allowUnknownAirports,
          );
          if (record == null) {
            skipped += 1;
          } else {
            records.add(record);
          }
        } else if (flightType == '1') {
          final record = _buildPositioningRecord(
            row,
            progressOrdinal: progressOrdinal,
            timeFormat: timeFormat,
            timezoneOffsetMinutes: options.timezoneOffsetMinutes,
            existingAirportsByIcao: existingAirportsByIcao,
            existingAirportsByIata: existingAirportsByIata,
            allowUnknownAirports: allowUnknownAirports,
          );
          if (record == null) {
            skipped += 1;
          } else {
            records.add(record);
          }
        } else if (flightType == '3') {
          final record = _buildSimulatorRecord(
            row,
            progressOrdinal: progressOrdinal,
            timeFormat: timeFormat,
            timezoneOffsetMinutes: options.timezoneOffsetMinutes,
          );
          if (record == null) {
            skipped += 1;
          } else {
            records.add(record);
          }
        } else {
          throw FormatException(
            'Line $sourceLineNumber: unsupported flight_type "$flightType".',
          );
        }
      } on _LogTenRowIssue catch (error) {
        final lineIssues = <LogTenImportIssue>[
          LogTenImportIssue(
            lineNumber: sourceLineNumber,
            association: error.association,
            currentValue: error.currentValue,
            reason: error.reason,
          ),
          ..._collectIndependentRowIssues(
            row,
            flightType: row.firstValue(LogTenFieldAssociation.flightType),
            timeFormat: timeFormat,
            timezoneOffsetMinutes: options.timezoneOffsetMinutes,
            existingAirportsByIcao: existingAirportsByIcao,
            existingAirportsByIata: existingAirportsByIata,
            allowUnknownAirports: allowUnknownAirports,
          ),
        ];
        final hasAirportIssue = lineIssues.any(
          (issue) =>
              issue.association == LogTenFieldAssociation.fromAirport ||
              issue.association == LogTenFieldAssociation.toAirport,
        );
        final hasSimulatorTime = row
            .firstValue(LogTenFieldAssociation.simulatorTime)
            .trim()
            .isNotEmpty;
        final canMarkAsSimulator = hasAirportIssue && hasSimulatorTime;
        final seen = <String>{};
        for (final issue in lineIssues) {
          final key =
              '${issue.lineNumber}|${issue.association.name}|${issue.reason}';
          if (seen.add(key)) {
            issues.add(
              LogTenImportIssue(
                lineNumber: issue.lineNumber,
                association: issue.association,
                currentValue: issue.currentValue,
                reason: issue.reason,
                canMarkAsSimulator: canMarkAsSimulator,
              ),
            );
          }
        }
        skipped += 1;
      }
    }

    return LogTenParseResult(
      batch: NormalizedImportBatch(
        totalRows: rows.length - 1,
        records: records,
        entityOptions: const ImportedEntityOptions(
          overrideAirportValues: false,
          overrideAircraftValues: false,
          overrideAircraftTypeValues: false,
          overrideCrewValues: false,
        ),
        skippedRows: skipped,
      ),
      issues: issues,
    );
  }

  List<LogTenImportIssue> _collectIndependentRowIssues(
    _LogTenRow row, {
    required String flightType,
    required _LogTenTimeFormat timeFormat,
    required int timezoneOffsetMinutes,
    required Map<String, Airport> existingAirportsByIcao,
    required Map<String, Airport> existingAirportsByIata,
    required bool allowUnknownAirports,
  }) {
    final issues = <LogTenImportIssue>[];

    void collect(void Function() callback) {
      try {
        callback();
      } on _LogTenRowIssue catch (error) {
        issues.add(
          LogTenImportIssue(
            lineNumber: row.lineNumber,
            association: error.association,
            currentValue: error.currentValue,
            reason: error.reason,
          ),
        );
      }
    }

    if (flightType.isEmpty || flightType == '1') {
      collect(() {
        _parseDate(
          row.requiredValue(LogTenFieldAssociation.date),
          row.lineNumber,
          timezoneOffsetMinutes,
          LogTenFieldAssociation.date,
        );
      });
      collect(() {
        _resolveAirport(
          row.requiredValue(LogTenFieldAssociation.fromAirport),
          lineNumber: row.lineNumber,
          association: LogTenFieldAssociation.fromAirport,
          existingAirportsByIcao: existingAirportsByIcao,
          existingAirportsByIata: existingAirportsByIata,
          allowUnknownAirports: allowUnknownAirports,
        );
      });
      collect(() {
        _resolveAirport(
          row.requiredValue(LogTenFieldAssociation.toAirport),
          lineNumber: row.lineNumber,
          association: LogTenFieldAssociation.toAirport,
          existingAirportsByIcao: existingAirportsByIcao,
          existingAirportsByIata: existingAirportsByIata,
          allowUnknownAirports: allowUnknownAirports,
        );
      });
      return issues;
    }

    if (flightType == '3') {
      collect(() {
        _parseDate(
          row.requiredValue(LogTenFieldAssociation.date),
          row.lineNumber,
          timezoneOffsetMinutes,
          LogTenFieldAssociation.date,
        );
      });
      collect(() {
        _parseOptionalDuration(
          row.firstValue(LogTenFieldAssociation.simulatorTime),
          timeFormat,
          row.lineNumber,
          LogTenFieldAssociation.simulatorTime,
        );
      });
      collect(() {
        final code = row
            .firstValue(LogTenFieldAssociation.aircraftTypeCode)
            .trim()
            .toUpperCase();
        if (code.isEmpty) {
          throw _LogTenRowIssue(
            lineNumber: row.lineNumber,
            association: LogTenFieldAssociation.aircraftTypeCode,
            currentValue: row.firstValue(
              LogTenFieldAssociation.aircraftTypeCode,
            ),
            reason: 'Simulator row is missing aircraft type.',
          );
        }
      });
      collect(() {
        final registration = row
            .firstValue(LogTenFieldAssociation.registration)
            .trim()
            .toUpperCase();
        if (registration.isEmpty) {
          throw _LogTenRowIssue(
            lineNumber: row.lineNumber,
            association: LogTenFieldAssociation.registration,
            currentValue: row.firstValue(LogTenFieldAssociation.registration),
            reason: 'Simulator row is missing aircraft registration.',
          );
        }
      });
    }

    return issues;
  }

  NormalizedFlightRecord? _buildFlightRecord(
    _LogTenRow row, {
    required int progressOrdinal,
    required _LogTenTimeFormat timeFormat,
    required int timezoneOffsetMinutes,
    required Map<String, Airport> existingAirportsByIcao,
    required Map<String, Airport> existingAirportsByIata,
    required bool allowUnknownAirports,
  }) {
    final date = _parseDate(
      row.requiredValue(LogTenFieldAssociation.date),
      row.lineNumber,
      timezoneOffsetMinutes,
      LogTenFieldAssociation.date,
    );
    final departureAirport = _resolveAirport(
      row.requiredValue(LogTenFieldAssociation.fromAirport),
      lineNumber: row.lineNumber,
      association: LogTenFieldAssociation.fromAirport,
      existingAirportsByIcao: existingAirportsByIcao,
      existingAirportsByIata: existingAirportsByIata,
      allowUnknownAirports: allowUnknownAirports,
    );
    final arrivalAirport = _resolveAirport(
      row.requiredValue(LogTenFieldAssociation.toAirport),
      lineNumber: row.lineNumber,
      association: LogTenFieldAssociation.toAirport,
      existingAirportsByIcao: existingAirportsByIcao,
      existingAirportsByIata: existingAirportsByIata,
      allowUnknownAirports: allowUnknownAirports,
    );
    final departureDateTime =
        _parseOptionalDateTime(
          date,
          row.firstValue(LogTenFieldAssociation.actualDepartureTime),
          row.lineNumber,
          timezoneOffsetMinutes,
          LogTenFieldAssociation.actualDepartureTime,
        ) ??
        date;
    final arrivalDateTime = _parseOptionalDateTime(
      date,
      row.firstValue(LogTenFieldAssociation.actualArrivalTime),
      row.lineNumber,
      timezoneOffsetMinutes,
      LogTenFieldAssociation.actualArrivalTime,
    );
    final takeOffDateTime = _parseOptionalDateTime(
      date,
      row.firstValue(LogTenFieldAssociation.takeoffTime),
      row.lineNumber,
      timezoneOffsetMinutes,
      LogTenFieldAssociation.takeoffTime,
    );
    final landingDateTime = _parseOptionalDateTime(
      date,
      row.firstValue(LogTenFieldAssociation.landingTime),
      row.lineNumber,
      timezoneOffsetMinutes,
      LogTenFieldAssociation.landingTime,
    );

    final resolvedArrival = _resolveEndAfterStart(
      start: departureDateTime,
      end: arrivalDateTime,
    );
    final resolvedTakeoff = _resolveEndAfterStart(
      start: departureDateTime,
      end: takeOffDateTime,
    );
    final resolvedLanding = _resolveEndAfterStart(
      start: resolvedTakeoff ?? departureDateTime,
      end: landingDateTime,
    );

    final blockMinutes =
        _parseOptionalDuration(
          row.firstValue(LogTenFieldAssociation.totalTime),
          timeFormat,
          row.lineNumber,
          LogTenFieldAssociation.totalTime,
        ) ??
        0;

    final aircraftType = _buildAircraftTypeDraft(row, timeFormat);
    final aircraft = _buildAircraftDraft(row, isSimulator: false);
    if (aircraft.registration.isEmpty && aircraftType.code.isEmpty) {
      return null;
    }

    final distanceNm = _parseDistanceNm(
      row.firstValue(LogTenFieldAssociation.distance),
      lineNumber: row.lineNumber,
      association: LogTenFieldAssociation.distance,
    );
    final resolvedDistanceNm =
        distanceNm ??
        _calculateDistanceNm(
          departureAirport,
          arrivalAirport,
          departureDateTime,
          resolvedArrival,
        );

    return NormalizedFlightRecord(
      progressOrdinal: progressOrdinal,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      aircraftType: aircraftType,
      aircraft: aircraft,
      departureDateTime: departureDateTime,
      takeOffDateTime: resolvedTakeoff,
      landingDateTime: resolvedLanding,
      arrivalDateTime: resolvedArrival,
      timePicMinutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.picTime),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.picTime,
          ) ??
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.soloTime),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.soloTime,
          ) ??
          0,
      timePicusMinutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.p1usTime),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.p1usTime,
          ) ??
          0,
      timeSicMinutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.sicTime),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.sicTime,
          ) ??
          0,
      timeDualMinutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.dualReceivedTime),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.dualReceivedTime,
          ) ??
          0,
      timeInstructorMinutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.dualGivenTime),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.dualGivenTime,
          ) ??
          0,
      timeIfrMinutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.ifrTime),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.ifrTime,
          ) ??
          0,
      timeNightMinutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.nightTime),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.nightTime,
          ) ??
          0,
      timeCrossCountryMinutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.crossCountryTime),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.crossCountryTime,
          ) ??
          0,
      timeCustom1Minutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.customTime1),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.customTime1,
          ) ??
          0,
      timeCustom2Minutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.customTime2),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.customTime2,
          ) ??
          0,
      timeCustom3Minutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.customTime3),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.customTime3,
          ) ??
          0,
      timeCustom4Minutes:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.customTime4),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.customTime4,
          ) ??
          0,
      timeFlightMinutes: 0,
      timeBlockMinutes: blockMinutes,
      timeTotalBlockMinutes: blockMinutes,
      distanceNm: resolvedDistanceNm,
      ifrApproaches: 0,
      takeoffsDay: _parseOptionalInt(
        row.firstValue(LogTenFieldAssociation.dayTakeoffs),
        LogTenFieldAssociation.dayTakeoffs,
      ),
      takeoffsNight: _parseOptionalInt(
        row.firstValue(LogTenFieldAssociation.nightTakeoffs),
        LogTenFieldAssociation.nightTakeoffs,
      ),
      landingsDay: _parseOptionalInt(
        row.firstValue(LogTenFieldAssociation.dayLandings),
        LogTenFieldAssociation.dayLandings,
      ),
      landingsNight: _parseOptionalInt(
        row.firstValue(LogTenFieldAssociation.nightLandings),
        LogTenFieldAssociation.nightLandings,
      ),
      pilotFunction: 'PF',
      approachType: '',
      remarks: row.firstValue(LogTenFieldAssociation.remarks),
      notes: _buildFlightNotes(row),
      crewAssignments: _buildCrewAssignments(row),
    );
  }

  NormalizedPositioningRecord? _buildPositioningRecord(
    _LogTenRow row, {
    required int progressOrdinal,
    required _LogTenTimeFormat timeFormat,
    required int timezoneOffsetMinutes,
    required Map<String, Airport> existingAirportsByIcao,
    required Map<String, Airport> existingAirportsByIata,
    required bool allowUnknownAirports,
  }) {
    final date = _parseDate(
      row.requiredValue(LogTenFieldAssociation.date),
      row.lineNumber,
      timezoneOffsetMinutes,
      LogTenFieldAssociation.date,
    );
    final departureAirport = _resolveAirport(
      row.requiredValue(LogTenFieldAssociation.fromAirport),
      lineNumber: row.lineNumber,
      association: LogTenFieldAssociation.fromAirport,
      existingAirportsByIcao: existingAirportsByIcao,
      existingAirportsByIata: existingAirportsByIata,
      allowUnknownAirports: allowUnknownAirports,
    );
    final arrivalAirport = _resolveAirport(
      row.requiredValue(LogTenFieldAssociation.toAirport),
      lineNumber: row.lineNumber,
      association: LogTenFieldAssociation.toAirport,
      existingAirportsByIcao: existingAirportsByIcao,
      existingAirportsByIata: existingAirportsByIata,
      allowUnknownAirports: allowUnknownAirports,
    );
    final departureDateTime =
        _parseOptionalDateTime(
          date,
          row.firstValue(LogTenFieldAssociation.actualDepartureTime),
          row.lineNumber,
          timezoneOffsetMinutes,
          LogTenFieldAssociation.actualDepartureTime,
        ) ??
        date;
    final arrivalDateTime = _resolveEndAfterStart(
      start: departureDateTime,
      end: _parseOptionalDateTime(
        date,
        row.firstValue(LogTenFieldAssociation.actualArrivalTime),
        row.lineNumber,
        timezoneOffsetMinutes,
        LogTenFieldAssociation.actualArrivalTime,
      ),
    );
    final totalMinutes =
        _parseOptionalDuration(
          row.firstValue(LogTenFieldAssociation.totalTime),
          timeFormat,
          row.lineNumber,
          LogTenFieldAssociation.totalTime,
        ) ??
        0;
    return NormalizedPositioningRecord(
      progressOrdinal: progressOrdinal,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      departureDateTime: departureDateTime,
      arrivalDateTime: arrivalDateTime,
      timeTotalMinutes: totalMinutes,
      notes: _buildFlightNotes(row),
    );
  }

  NormalizedSimulatorRecord? _buildSimulatorRecord(
    _LogTenRow row, {
    required int progressOrdinal,
    required _LogTenTimeFormat timeFormat,
    required int timezoneOffsetMinutes,
  }) {
    final date = _parseDate(
      row.requiredValue(LogTenFieldAssociation.date),
      row.lineNumber,
      timezoneOffsetMinutes,
      LogTenFieldAssociation.date,
    );
    final total = _parseOptionalDuration(
      row.firstValue(LogTenFieldAssociation.simulatorTime),
      timeFormat,
      row.lineNumber,
      LogTenFieldAssociation.simulatorTime,
    );
    if (total == null || total <= 0) {
      return null;
    }
    final aircraftType = _buildAircraftTypeDraft(row, timeFormat);
    if (aircraftType.code.isEmpty) {
      throw _LogTenRowIssue(
        lineNumber: row.lineNumber,
        association: LogTenFieldAssociation.aircraftTypeCode,
        currentValue: row.firstValue(LogTenFieldAssociation.aircraftTypeCode),
        reason: 'Simulator row is missing aircraft type.',
      );
    }
    final aircraft = _buildAircraftDraft(row, isSimulator: true);
    if (aircraft.registration.isEmpty) {
      throw _LogTenRowIssue(
        lineNumber: row.lineNumber,
        association: LogTenFieldAssociation.registration,
        currentValue: row.firstValue(LogTenFieldAssociation.registration),
        reason: 'Simulator row is missing aircraft registration.',
      );
    }
    final startDateTime =
        _parseOptionalDateTime(
          date,
          row.firstValue(LogTenFieldAssociation.actualDepartureTime),
          row.lineNumber,
          timezoneOffsetMinutes,
          LogTenFieldAssociation.actualDepartureTime,
        ) ??
        date;
    return NormalizedSimulatorRecord(
      progressOrdinal: progressOrdinal,
      aircraftType: aircraftType,
      aircraft: aircraft,
      startDateTime: startDateTime,
      endDateTime: startDateTime.add(Duration(minutes: total)),
      timeTotal: total,
      remarks: row.firstValue(LogTenFieldAssociation.remarks),
      notes: _buildFlightNotes(row),
      crewAssignments: _buildCrewAssignments(row),
    );
  }

  ImportedAircraftTypeDraft _buildAircraftTypeDraft(
    _LogTenRow row,
    _LogTenTimeFormat timeFormat,
  ) {
    final code = row
        .firstValue(LogTenFieldAssociation.aircraftTypeCode)
        .trim()
        .toUpperCase();
    final hasWaterOps =
        _parseOptionalInt(
              row.firstValue(LogTenFieldAssociation.waterLandings),
              LogTenFieldAssociation.waterLandings,
            ) >
            0 ||
        _parseOptionalInt(
              row.firstValue(LogTenFieldAssociation.waterTakeoffs),
              LogTenFieldAssociation.waterTakeoffs,
            ) >
            0;
    return ImportedAircraftTypeDraft(
      code: code,
      family: code,
      longName: row.firstValue(LogTenFieldAssociation.aircraftTypeModel).trim(),
      manufacturer: row
          .firstValue(LogTenFieldAssociation.aircraftTypeManufacturer)
          .trim(),
      category: _mapCategory(
        row.firstValue(LogTenFieldAssociation.aircraftTypeCategory),
        hasWaterOps: hasWaterOps,
        lineNumber: row.lineNumber,
        association: LogTenFieldAssociation.aircraftTypeCategory,
      ),
      engineType: _mapEngineType(
        row.firstValue(LogTenFieldAssociation.aircraftTypeEngineType),
        aircraftTypeCode: code,
        lineNumber: row.lineNumber,
        association: LogTenFieldAssociation.aircraftTypeEngineType,
      ),
      mtow: 0,
      engineCount: 1,
      multiPilot:
          _parseOptionalDuration(
            row.firstValue(LogTenFieldAssociation.multiPilotTime),
            timeFormat,
            row.lineNumber,
            LogTenFieldAssociation.multiPilotTime,
          ) !=
          null,
      complex: _parseBool(
        row.firstValue(LogTenFieldAssociation.aircraftComplex),
      ),
      efis: _parseBool(row.firstValue(LogTenFieldAssociation.aircraftEfis)),
      highPerformance: _parseBool(
        row.firstValue(LogTenFieldAssociation.aircraftHighPerformance),
      ),
    );
  }

  ImportedAircraftDraft _buildAircraftDraft(
    _LogTenRow row, {
    required bool isSimulator,
  }) {
    return ImportedAircraftDraft(
      registration: row
          .firstValue(LogTenFieldAssociation.registration)
          .trim()
          .toUpperCase(),
      mtow: _parseOptionalInt(
        row.firstValue(LogTenFieldAssociation.mtow),
        LogTenFieldAssociation.mtow,
      ),
      isSimulator: isSimulator,
      notes: row.firstValue(LogTenFieldAssociation.aircraftNotes).trim(),
    );
  }

  List<ImportedCrewAssignmentDraft> _buildCrewAssignments(_LogTenRow row) {
    final assignments = <ImportedCrewAssignmentDraft>[];
    final seen = <String>{};

    void addAll(LogTenFieldAssociation association, CrewPosition position) {
      for (final name in row.valuesFor(association)) {
        final clean = name.trim();
        if (clean.isEmpty) continue;
        final key = '${clean.toLowerCase()}|${position.name}';
        if (!seen.add(key)) continue;
        assignments.add(
          ImportedCrewAssignmentDraft.crew(
            position: position,
            crew: ImportedCrewDraft(name: clean),
          ),
        );
      }
    }

    addAll(LogTenFieldAssociation.crewPic, CrewPosition.pic);
    addAll(LogTenFieldAssociation.crewSic, CrewPosition.sic);
    addAll(LogTenFieldAssociation.crewRelief, CrewPosition.relief);
    addAll(LogTenFieldAssociation.crewEngineer, CrewPosition.other);
    addAll(LogTenFieldAssociation.crewInstructor, CrewPosition.instructor);
    addAll(LogTenFieldAssociation.crewStudent, CrewPosition.trainee);
    addAll(LogTenFieldAssociation.crewObserver, CrewPosition.observer);
    addAll(LogTenFieldAssociation.crewCabinCrew, CrewPosition.cabinCrew);
    addAll(LogTenFieldAssociation.crewCommander, CrewPosition.pic);
    addAll(LogTenFieldAssociation.crewOther, CrewPosition.other);
    return assignments;
  }

  ImportedAirportDraft _resolveAirport(
    String rawCode, {
    required int lineNumber,
    required LogTenFieldAssociation association,
    required Map<String, Airport> existingAirportsByIcao,
    required Map<String, Airport> existingAirportsByIata,
    required bool allowUnknownAirports,
  }) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      throw _LogTenRowIssue(
        lineNumber: lineNumber,
        association: association,
        currentValue: rawCode,
        reason: 'Airport code is empty.',
      );
    }
    if (code.length == 4) {
      final existing = existingAirportsByIcao[code.toLowerCase()];
      if (existing == null) {
        if (allowUnknownAirports) {
          return _unknownAirportDraft(code);
        }
        throw _LogTenRowIssue(
          lineNumber: lineNumber,
          association: association,
          currentValue: rawCode,
          reason: 'ICAO airport "$code" does not exist in the database.',
        );
      }
      return _airportDraftFromAirport(existing);
    }
    if (code.length == 3) {
      final existing = existingAirportsByIata[code.toLowerCase()];
      if (existing == null) {
        if (allowUnknownAirports) {
          return _unknownAirportDraft(code, iata: code);
        }
        throw _LogTenRowIssue(
          lineNumber: lineNumber,
          association: association,
          currentValue: rawCode,
          reason: 'IATA airport "$code" does not exist in the database.',
        );
      }
      return _airportDraftFromAirport(existing);
    }
    throw _LogTenRowIssue(
      lineNumber: lineNumber,
      association: association,
      currentValue: rawCode,
      reason: 'Invalid airport code "$code". Expected ICAO (4) or IATA (3).',
    );
  }

  ImportedAirportDraft _unknownAirportDraft(String icao, {String iata = ''}) {
    return ImportedAirportDraft(
      icao: icao,
      iata: iata,
    );
  }

  ImportedAirportDraft _airportDraftFromAirport(Airport airport) {
    return ImportedAirportDraft(
      icao: airport.icao,
      iata: airport.iata ?? '',
      name: airport.name ?? '',
      city: airport.city ?? '',
      country: airport.country ?? '',
      latitude: airport.latitude,
      longitude: airport.longitude,
      latitudeRaw: airport.latitude == 0 ? '' : '${airport.latitude}',
      longitudeRaw: airport.longitude == 0 ? '' : '${airport.longitude}',
    );
  }

  int _calculateDistanceNm(
    ImportedAirportDraft departureAirport,
    ImportedAirportDraft arrivalAirport,
    DateTime departureDateTime,
    DateTime? arrivalDateTime,
  ) {
    if (arrivalDateTime == null ||
        !_hasCoords(
          departureAirport.latitude,
          departureAirport.longitude,
          arrivalAirport.latitude,
          arrivalAirport.longitude,
        )) {
      return 0;
    }
    final calculations = FlightCalculations(
      latDep: departureAirport.latitude,
      longDep: departureAirport.longitude,
      latArr: arrivalAirport.latitude,
      longArr: arrivalAirport.longitude,
      depTimeEpochSeconds: departureDateTime.millisecondsSinceEpoch ~/ 1000,
      arrTimeEpochSeconds: arrivalDateTime.millisecondsSinceEpoch ~/ 1000,
    );
    return calculations.flightDistanceNm.round();
  }

  bool _hasCoords(double aLat, double aLon, double bLat, double bLon) {
    return aLat != 0 && aLon != 0 && bLat != 0 && bLon != 0;
  }

  String _buildFlightNotes(_LogTenRow row) {
    final parts = <String>[];
    final flightNumber = row.firstValue(LogTenFieldAssociation.flightNumber);
    if (flightNumber.isNotEmpty) {
      parts.add('Flight Number: $flightNumber');
    }
    return parts.join('\n');
  }

  DateTime _parseDate(
    String value,
    int lineNumber,
    int timezoneOffsetMinutes,
    LogTenFieldAssociation association,
  ) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw _LogTenRowIssue(
        lineNumber: lineNumber,
        association: association,
        currentValue: value,
        reason: 'Missing date.',
      );
    }
    final dashParts = trimmed.split('-');
    final slashParts = trimmed.split('/');
    final parts = dashParts.length == 3 ? dashParts : slashParts;
    if (parts.length != 3) {
      throw _LogTenRowIssue(
        lineNumber: lineNumber,
        association: association,
        currentValue: value,
        reason: 'Invalid date "$trimmed".',
      );
    }
    try {
      final isSlashDate = slashParts.length == 3 && dashParts.length != 3;
      final year = int.parse(isSlashDate ? parts[2] : parts[0]);
      final month = int.parse(isSlashDate ? parts[0] : parts[1]);
      final day = int.parse(isSlashDate ? parts[1] : parts[2]);
      return DateTime.utc(
        year,
        month,
        day,
      ).subtract(Duration(minutes: timezoneOffsetMinutes));
    } on FormatException {
      throw _LogTenRowIssue(
        lineNumber: lineNumber,
        association: association,
        currentValue: value,
        reason: 'Invalid date "$trimmed".',
      );
    }
  }

  DateTime? _parseOptionalDateTime(
    DateTime baseDateUtc,
    String value,
    int lineNumber,
    int timezoneOffsetMinutes,
    LogTenFieldAssociation association,
  ) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split(':');
    if (parts.length < 2 || parts.length > 3) {
      throw _LogTenRowIssue(
        lineNumber: lineNumber,
        association: association,
        currentValue: value,
        reason: 'Invalid time "$trimmed".',
      );
    }
    final localDate = baseDateUtc.add(Duration(minutes: timezoneOffsetMinutes));
    final localDateTime = DateTime.utc(
      localDate.year,
      localDate.month,
      localDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length == 3 ? int.parse(parts[2]) : 0,
    );
    return localDateTime.subtract(Duration(minutes: timezoneOffsetMinutes));
  }

  DateTime? _resolveEndAfterStart({
    required DateTime start,
    required DateTime? end,
  }) {
    if (end == null) return null;
    return end.isBefore(start) ? end.add(const Duration(days: 1)) : end;
  }

  int? _parseOptionalDuration(
    String value,
    _LogTenTimeFormat format,
    int lineNumber,
    LogTenFieldAssociation association,
  ) {
    final trimmed = _normalizeNumericText(value, association: association);
    if (trimmed.isEmpty) return null;
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      if (parts.length != 2) {
        throw _LogTenRowIssue(
          lineNumber: lineNumber,
          association: association,
          currentValue: value,
          reason: 'Invalid duration "$trimmed".',
        );
      }
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      if (hours == null || minutes == null) {
        throw _LogTenRowIssue(
          lineNumber: lineNumber,
          association: association,
          currentValue: value,
          reason: 'Invalid duration "$trimmed".',
        );
      }
      return (hours * 60) + minutes;
    }
    final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
    if (parsed == null) {
      throw _LogTenRowIssue(
        lineNumber: lineNumber,
        association: association,
        currentValue: value,
        reason: 'Invalid duration "$trimmed".',
      );
    }
    return (parsed * 60).round();
  }

  int? _parseDistanceNm(
    String value, {
    required int lineNumber,
    required LogTenFieldAssociation association,
  }) {
    final trimmed = _normalizeNumericText(value, association: association);
    if (trimmed.isEmpty) return null;
    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      throw _LogTenRowIssue(
        lineNumber: lineNumber,
        association: association,
        currentValue: value,
        reason: 'Invalid distance "${value.trim()}".',
      );
    }
    return parsed.round();
  }

  int _parseOptionalInt(String value, LogTenFieldAssociation association) {
    return int.tryParse(
          _normalizeNumericText(value, association: association),
        ) ??
        0;
  }

  bool _parseBool(String value) {
    final trimmed = value.trim().toLowerCase();
    return trimmed == '1' || trimmed == 'true' || trimmed == 'yes';
  }

  EngineType _mapEngineType(
    String value, {
    required String aircraftTypeCode,
    required int lineNumber,
    required LogTenFieldAssociation association,
  }) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      '' =>
        _inferEngineType(aircraftTypeCode) ??
            (throw _LogTenRowIssue(
              lineNumber: lineNumber,
              association: association,
              currentValue: value,
              reason:
                  'Missing engine type for aircraft type "$aircraftTypeCode".',
            )),
      'jet' => EngineType.jet,
      'reciprocating' => EngineType.piston,
      'turboprop' => EngineType.turboprop,
      'turbo prop' => EngineType.turboprop,
      'electric' => EngineType.electric,
      _ => throw _LogTenRowIssue(
        lineNumber: lineNumber,
        association: association,
        currentValue: value,
        reason: 'Unsupported engine type "$value".',
      ),
    };
  }

  EngineType? _inferEngineType(String aircraftTypeCode) {
    final code = aircraftTypeCode.trim().toUpperCase();
    if (code.isEmpty) return null;
    if (RegExp(
      '^(737|B[0-9]|A[0-9]|MD-|T-1|T-37|T-38|AT-38|EF-|F-|E-3)',
    ).hasMatch(code)) {
      return EngineType.jet;
    }
    if (RegExp('^(PA-|C-|T-34|T-41)').hasMatch(code)) {
      return EngineType.piston;
    }
    return null;
  }

  AircraftCategory _mapCategory(
    String value, {
    required bool hasWaterOps,
    required int lineNumber,
    required LogTenFieldAssociation association,
  }) {
    final normalized = value.trim().toLowerCase();
    if (hasWaterOps) {
      return AircraftCategory.seaplane;
    }
    return switch (normalized) {
      '' => AircraftCategory.landplane,
      'airplane' => AircraftCategory.landplane,
      'training device' => AircraftCategory.landplane,
      'helicopter' => AircraftCategory.helicopter,
      _ => throw _LogTenRowIssue(
        lineNumber: lineNumber,
        association: association,
        currentValue: value,
        reason: 'Unsupported aircraft category "$value".',
      ),
    };
  }

  _LogTenTimeFormat _detectTimeFormat(
    Iterable<List<String>> rows,
    Map<String, int> headerIndex,
    _LogTenMappingPlan plan,
    LogTenImportOptions options,
  ) {
    const durationAssociations = <LogTenFieldAssociation>{
      LogTenFieldAssociation.totalTime,
      LogTenFieldAssociation.picTime,
      LogTenFieldAssociation.sicTime,
      LogTenFieldAssociation.nightTime,
      LogTenFieldAssociation.crossCountryTime,
      LogTenFieldAssociation.ifrTime,
      LogTenFieldAssociation.dualReceivedTime,
      LogTenFieldAssociation.dualGivenTime,
      LogTenFieldAssociation.simulatorTime,
      LogTenFieldAssociation.soloTime,
      LogTenFieldAssociation.p1usTime,
      LogTenFieldAssociation.multiPilotTime,
      LogTenFieldAssociation.customTime1,
      LogTenFieldAssociation.customTime2,
      LogTenFieldAssociation.customTime3,
      LogTenFieldAssociation.customTime4,
    };
    final durationColumns = <int>{
      for (final association in durationAssociations)
        ...plan
            .columnsFor(association)
            .map((column) => headerIndex[column])
            .whereType<int>(),
    };
    var sawHhMm = false;
    var sawDecimal = false;
    var rowOffset = 0;
    for (final row in rows) {
      final lineNumber = rowOffset + 2;
      rowOffset += 1;
      if (options.ignoredLines.contains(lineNumber)) {
        continue;
      }
      for (final index in durationColumns) {
        if (index >= row.length) continue;
        final columnName = headerIndex.entries
            .firstWhere((entry) => entry.value == index)
            .key;
        final association =
            options.assignments[columnName] ?? LogTenFieldAssociation.ignore;
        final value =
            options.valueOverrides[lineNumber]?[association]?.trim() ??
            row[index].trim();
        if (value.isEmpty) continue;
        if (value.contains(':')) {
          sawHhMm = true;
        } else {
          sawDecimal = true;
        }
      }
    }
    if (sawHhMm && sawDecimal) {
      // Mixed format exports are valid; durations are parsed per-cell.
      return _LogTenTimeFormat.hhMm;
    }
    return sawHhMm ? _LogTenTimeFormat.hhMm : _LogTenTimeFormat.decimal;
  }

  List<List<String>> _parseTsv(String content) {
    return content
        .split(RegExp(r'\r\n|\n|\r'))
        .where((line) => line.isNotEmpty)
        .map((line) => line.split('\t'))
        .toList(growable: false);
  }
}

class _LogTenRow {
  const _LogTenRow({
    required this.values,
    required this.headerIndex,
    required this.lineNumber,
    required this.plan,
    required this.options,
  });

  final List<String> values;
  final Map<String, int> headerIndex;
  final int lineNumber;
  final _LogTenMappingPlan plan;
  final LogTenImportOptions options;

  String firstValue(LogTenFieldAssociation association) {
    final override = options.valueOverrides[lineNumber]?[association];
    if (override != null) {
      return override.trim();
    }
    for (final column in plan.columnsFor(association)) {
      final index = headerIndex[column];
      if (index == null || index >= values.length) continue;
      final value = values[index].trim();
      if (value.isNotEmpty) return value;
    }
    if (association == LogTenFieldAssociation.fromAirport ||
        association == LogTenFieldAssociation.toAirport) {
      final route = firstValue(LogTenFieldAssociation.route);
      final stops = route
          .split(RegExp(r'\s*(?:-|→|>)\s*|\s+'))
          .where((value) => value.trim().isNotEmpty)
          .toList(growable: false);
      if (stops.isNotEmpty) {
        return association == LogTenFieldAssociation.fromAirport
            ? stops.first
            : stops.last;
      }
    }
    return '';
  }

  String requiredValue(LogTenFieldAssociation association) {
    final value = firstValue(association);
    if (value.isNotEmpty) return value;
    throw _LogTenRowIssue(
      lineNumber: lineNumber,
      association: association,
      currentValue: '',
      reason: 'Missing ${association.label.toLowerCase()}.',
    );
  }

  List<String> valuesFor(LogTenFieldAssociation association) {
    final override = options.valueOverrides[lineNumber]?[association];
    if (override != null) {
      final trimmed = override.trim();
      return trimmed.isEmpty ? const <String>[] : <String>[trimmed];
    }
    final result = <String>[];
    for (final column in plan.columnsFor(association)) {
      final index = headerIndex[column];
      if (index == null || index >= values.length) continue;
      final value = values[index].trim();
      if (value.isNotEmpty) {
        result.add(value);
      }
    }
    return result;
  }
}

class _LogTenMappingPlan {
  const _LogTenMappingPlan(this.columnsByAssociation);

  factory _LogTenMappingPlan.fromAssignments({
    required Map<String, LogTenFieldAssociation> assignments,
    required List<String> header,
  }) {
    final columnsByAssociation = <LogTenFieldAssociation, List<String>>{};
    for (final column in header) {
      final association = assignments[column] ?? LogTenFieldAssociation.ignore;
      columnsByAssociation
          .putIfAbsent(association, () => <String>[])
          .add(column);
    }
    return _LogTenMappingPlan(columnsByAssociation);
  }

  final Map<LogTenFieldAssociation, List<String>> columnsByAssociation;

  List<String> columnsFor(LogTenFieldAssociation association) {
    return columnsByAssociation[association] ?? const <String>[];
  }
}

enum _LogTenTimeFormat { hhMm, decimal }

class _LogTenRowIssue implements Exception {
  const _LogTenRowIssue({
    required this.lineNumber,
    required this.association,
    required this.currentValue,
    required this.reason,
  });

  final int lineNumber;
  final LogTenFieldAssociation association;
  final String currentValue;
  final String reason;
}

String _normalizeNumericText(
  String value, {
  required LogTenFieldAssociation association,
}) {
  final trimmed = value.trim();
  if (association == LogTenFieldAssociation.distance) {
    return trimmed.replaceAll(',', '');
  }
  return trimmed;
}
