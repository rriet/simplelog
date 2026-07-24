import 'package:intl/intl.dart';
import 'package:simplelog/core/flight/flight_calculations.dart';
import 'package:simplelog/core/flight/ifr_calculation.dart';
import 'package:simplelog/core/flight/pilot_function_logic.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/simplelog_csv_support.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Missing required value detected in a Southwest source row.
enum SouthwestMissingRequiredField {
  /// Missing DATE.
  date,

  /// Missing departure airport.
  departureAirport,

  /// Missing arrival airport.
  arrivalAirport,

  /// Missing departure time.
  departureTime,

  /// Missing arrival time.
  arrivalTime,
}

/// One source line with missing required values.
class SouthwestMissingRequiredIssue {
  /// Creates a missing-required-fields issue.
  const SouthwestMissingRequiredIssue({
    required this.sourceLineNumber,
    required this.missingFields,
  });

  /// 1-based source line number in the CSV file.
  final int sourceLineNumber;

  /// Missing required fields for this line.
  final Set<SouthwestMissingRequiredField> missingFields;
}

/// One source line with missing aircraft type.
class SouthwestMissingAircraftTypeIssue {
  /// Creates a missing-aircraft-type issue.
  const SouthwestMissingAircraftTypeIssue({required this.sourceLineNumber});

  /// 1-based source line number in the CSV file.
  final int sourceLineNumber;
}

/// One source line with missing aircraft tail.
class SouthwestMissingAircraftTailIssue {
  /// Creates a missing-aircraft-tail issue.
  const SouthwestMissingAircraftTailIssue({
    required this.sourceLineNumber,
    required this.date,
    required this.fromCode,
    required this.toCode,
    required this.aircraftTypeCode,
  });

  /// 1-based source line number in the CSV file.
  final int sourceLineNumber;

  /// Flight date text from source row.
  final String date;

  /// Departure airport code from source row.
  final String fromCode;

  /// Arrival airport code from source row.
  final String toCode;

  /// Raw aircraft type code from this line.
  final String aircraftTypeCode;
}

/// Preflight validation output for a Southwest CSV file.
class SouthwestCsvPreflightReport {
  /// Creates a preflight report.
  const SouthwestCsvPreflightReport({
    required this.missingRequiredIssues,
    required this.missingAircraftTypeIssues,
    required this.missingAircraftTailIssues,
  });

  /// Rows with missing required fields.
  final List<SouthwestMissingRequiredIssue> missingRequiredIssues;

  /// Non-positioning rows with missing aircraft type.
  final List<SouthwestMissingAircraftTypeIssue> missingAircraftTypeIssues;

  /// Non-positioning rows with missing aircraft tail.
  final List<SouthwestMissingAircraftTailIssue> missingAircraftTailIssues;

  /// Whether this file has at least one blocking row issue.
  bool get hasIssues =>
      missingRequiredIssues.isNotEmpty ||
      missingAircraftTypeIssues.isNotEmpty ||
      missingAircraftTailIssues.isNotEmpty;
}

/// Parses Southwest CSV exports into normalized import records.
class SouthwestCsvSourceParser {
  /// Creates a parser.
  const SouthwestCsvSourceParser();

  /// Extracts unique raw aircraft type designators from non-positioning rows.
  ///
  /// Empty designators are represented by an empty string.
  Set<String> extractUniqueRawTypeCodes(
    String content, {
    Set<String> existingAircraftRegistrations = const <String>{},
  }) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    final headerRowIndex = _findHeaderRowIndex(rows);
    if (headerRowIndex < 0) {
      throw const FormatException('Southwest CSV header not found.');
    }
    final indices = _SouthwestHeaderIndices(rows[headerRowIndex]);
    final normalizedExistingRegistrations = existingAircraftRegistrations
        .map(_normalizeSouthwestAircraftRegistration)
        .where((registration) => registration.isNotEmpty)
        .toSet();
    final types = <String>{};
    for (
      var rowIndex = headerRowIndex + 1;
      rowIndex < rows.length;
      rowIndex += 1
    ) {
      final row = rows[rowIndex];
      if (row.isEmpty) continue;
      String get(int idx) =>
          idx >= 0 && idx < row.length ? row[idx].trim() : '';
      if (get(indices.dhd).toUpperCase() == 'DH') {
        continue;
      }
      final registration = _normalizeSouthwestAircraftRegistration(
        get(indices.tail),
      );
      if (registration.isNotEmpty &&
          normalizedExistingRegistrations.contains(registration)) {
        continue;
      }
      final rawType = _normalizeSouthwestTypeCode(get(indices.type));
      types.add(rawType);
    }
    return types;
  }

  /// Collects aircraft registrations grouped by raw type.
  ///
  /// When [existingAircraftRegistrations] is provided, those registrations
  /// are excluded so the caller can focus on aircraft rows that still need
  /// creation.
  Map<String, List<String>> collectAircraftRegistrationsByRawType(
    String content, {
    Set<String> existingAircraftRegistrations = const <String>{},
  }) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    final headerRowIndex = _findHeaderRowIndex(rows);
    if (headerRowIndex < 0) {
      throw const FormatException('Southwest CSV header not found.');
    }
    final indices = _SouthwestHeaderIndices(rows[headerRowIndex]);
    final normalizedExistingRegistrations = existingAircraftRegistrations
        .map(_normalizeSouthwestAircraftRegistration)
        .where((registration) => registration.isNotEmpty)
        .toSet();
    final registrationsByRawType = <String, Set<String>>{};

    for (
      var rowIndex = headerRowIndex + 1;
      rowIndex < rows.length;
      rowIndex += 1
    ) {
      final row = rows[rowIndex];
      if (row.isEmpty) continue;
      String get(int idx) =>
          idx >= 0 && idx < row.length ? row[idx].trim() : '';
      if (get(indices.dhd).toUpperCase() == 'DH') {
        continue;
      }
      final registration = _normalizeSouthwestAircraftRegistration(
        get(indices.tail),
      );
      if (registration.isEmpty ||
          normalizedExistingRegistrations.contains(registration)) {
        continue;
      }
      final rawType = _normalizeSouthwestTypeCode(get(indices.type));
      registrationsByRawType
          .putIfAbsent(rawType, () => <String>{})
          .add(
            registration,
          );
    }

    return <String, List<String>>{
      for (final entry in registrationsByRawType.entries)
        entry.key: (entry.value.toList()..sort()),
    };
  }

  /// Infers raw Southwest type mappings from already existing aircraft rows.
  ///
  /// Returns only unambiguous mappings where one raw type resolves to exactly
  /// one existing aircraft type code.
  Map<String, String> inferTypeMappingsFromExistingAircraft(
    String content, {
    required Map<String, String> existingAircraftTypeCodesByRegistration,
  }) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    final headerRowIndex = _findHeaderRowIndex(rows);
    if (headerRowIndex < 0) {
      throw const FormatException('Southwest CSV header not found.');
    }
    final indices = _SouthwestHeaderIndices(rows[headerRowIndex]);
    final existingTypeByRegistration = <String, String>{
      for (final entry in existingAircraftTypeCodesByRegistration.entries)
        _normalizeSouthwestAircraftRegistration(
          entry.key,
        ): _normalizeSouthwestTypeCode(
          entry.value,
        ),
    };
    final candidatesByRawType = <String, Set<String>>{};

    for (
      var rowIndex = headerRowIndex + 1;
      rowIndex < rows.length;
      rowIndex += 1
    ) {
      final row = rows[rowIndex];
      if (row.isEmpty) continue;
      String get(int idx) =>
          idx >= 0 && idx < row.length ? row[idx].trim() : '';
      if (get(indices.dhd).toUpperCase() == 'DH') {
        continue;
      }
      final rawType = _normalizeSouthwestTypeCode(get(indices.type));
      if (rawType.isEmpty) {
        continue;
      }
      final registration = _normalizeSouthwestAircraftRegistration(
        get(indices.tail),
      );
      if (registration.isEmpty) {
        continue;
      }
      final existingType = existingTypeByRegistration[registration];
      if (existingType == null || existingType.isEmpty) {
        continue;
      }
      candidatesByRawType
          .putIfAbsent(rawType, () => <String>{})
          .add(
            existingType,
          );
    }

    final inferred = <String, String>{};
    for (final entry in candidatesByRawType.entries) {
      if (entry.value.length == 1) {
        inferred[entry.key] = entry.value.first;
      }
    }
    return inferred;
  }

  /// Inspects Southwest CSV rows and reports missing required values.
  SouthwestCsvPreflightReport inspect(
    String content, {
    SouthwestImportOptions options = const SouthwestImportOptions(),
  }) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    final headerRowIndex = _findHeaderRowIndex(rows);
    if (headerRowIndex < 0) {
      throw const FormatException('Southwest CSV header not found.');
    }

    final indices = _SouthwestHeaderIndices(
      rows[headerRowIndex],
    );
    final missingRequiredIssues = <SouthwestMissingRequiredIssue>[];
    final missingAircraftTypeIssues = <SouthwestMissingAircraftTypeIssue>[];
    final missingAircraftTailIssues = <SouthwestMissingAircraftTailIssue>[];

    for (
      var rowIndex = headerRowIndex + 1;
      rowIndex < rows.length;
      rowIndex += 1
    ) {
      final row = rows[rowIndex];
      if (row.isEmpty) continue;
      String get(int idx) =>
          idx >= 0 && idx < row.length ? row[idx].trim() : '';

      final sourceLineNumber = rowIndex + 1;
      if (options.skippedSourceLineNumbers.contains(sourceLineNumber)) {
        continue;
      }
      final lineOverrides = options.airportCodeOverrides[sourceLineNumber];
      final fromCode = lineOverrides?['from'] ?? get(indices.from);
      final toCode = lineOverrides?['to'] ?? get(indices.to);
      final missing = <SouthwestMissingRequiredField>{};
      if (get(indices.date).isEmpty) {
        missing.add(SouthwestMissingRequiredField.date);
      }
      if (fromCode.trim().isEmpty) {
        missing.add(SouthwestMissingRequiredField.departureAirport);
      }
      if (toCode.trim().isEmpty) {
        missing.add(SouthwestMissingRequiredField.arrivalAirport);
      }
      if (get(indices.depart).isEmpty) {
        missing.add(SouthwestMissingRequiredField.departureTime);
      }
      if (get(indices.arrive).isEmpty) {
        missing.add(SouthwestMissingRequiredField.arrivalTime);
      }
      if (missing.isNotEmpty) {
        missingRequiredIssues.add(
          SouthwestMissingRequiredIssue(
            sourceLineNumber: sourceLineNumber,
            missingFields: missing,
          ),
        );
        continue;
      }

      final isDeadhead = get(indices.dhd).toUpperCase() == 'DH';
      if (isDeadhead) continue;

      final typeCode = get(indices.type).toUpperCase();
      if (typeCode.isEmpty) {
        missingAircraftTypeIssues.add(
          SouthwestMissingAircraftTypeIssue(sourceLineNumber: sourceLineNumber),
        );
      }
      if (get(indices.tail).toUpperCase().isEmpty) {
        missingAircraftTailIssues.add(
          SouthwestMissingAircraftTailIssue(
            sourceLineNumber: sourceLineNumber,
            date: get(indices.date),
            fromCode: fromCode.toUpperCase(),
            toCode: toCode.toUpperCase(),
            aircraftTypeCode: typeCode,
          ),
        );
      }
    }

    return SouthwestCsvPreflightReport(
      missingRequiredIssues: missingRequiredIssues,
      missingAircraftTypeIssues: missingAircraftTypeIssues,
      missingAircraftTailIssues: missingAircraftTailIssues,
    );
  }

  /// Parses Southwest CSV content into a normalized batch.
  NormalizedImportBatch parse(
    String content, {
    SouthwestImportOptions options = const SouthwestImportOptions(),
    Map<String, Airport> existingAirportsByIcao = const {},
    bool hasSelfCrew = false,
  }) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    final headerRowIndex = _findHeaderRowIndex(rows);
    if (headerRowIndex < 0) {
      throw const FormatException('Southwest CSV header not found.');
    }

    final indices = _SouthwestHeaderIndices(rows[headerRowIndex]);
    final normalizedTypeMappings = _normalizeSouthwestTypeMappings(
      options.aircraftTypeMappings,
    );

    final records = <NormalizedImportRecord>[];
    var skipped = 0;
    var errors = 0;
    var progressOrdinal = 0;

    for (
      var rowIndex = headerRowIndex + 1;
      rowIndex < rows.length;
      rowIndex += 1
    ) {
      progressOrdinal += 1;
      final row = rows[rowIndex];
      if (row.isEmpty) continue;
      final sourceLineNumber = rowIndex + 1;
      if (options.skippedSourceLineNumbers.contains(sourceLineNumber)) {
        skipped += 1;
        continue;
      }

      try {
        String get(int idx) =>
            idx >= 0 && idx < row.length ? row[idx].trim() : '';

        final dateText = get(indices.date);
        final lineOverrides = options.airportCodeOverrides[sourceLineNumber];
        final fromCode = (lineOverrides?['from'] ?? get(indices.from))
            .toUpperCase();
        final toCode = (lineOverrides?['to'] ?? get(indices.to)).toUpperCase();
        final departText = get(indices.depart);
        final arriveText = get(indices.arrive);
        if (dateText.isEmpty ||
            fromCode.isEmpty ||
            toCode.isEmpty ||
            departText.isEmpty ||
            arriveText.isEmpty) {
          skipped += 1;
          continue;
        }

        final departureLocalDateTime = _parseSouthwestLocalDateTime(
          dateText,
          departText,
        );
        final arrivalLocalDateTime = _parseSouthwestLocalDateTime(
          dateText,
          arriveText,
        );
        if (departureLocalDateTime == null || arrivalLocalDateTime == null) {
          skipped += 1;
          continue;
        }
        var resolvedArrivalLocal = arrivalLocalDateTime;
        if (resolvedArrivalLocal.isBefore(departureLocalDateTime)) {
          resolvedArrivalLocal = resolvedArrivalLocal.add(
            const Duration(days: 1),
          );
        }
        final departureDateTime = _southwestCentralLocalToUtc(
          departureLocalDateTime,
        );
        final resolvedArrival = _southwestCentralLocalToUtc(
          resolvedArrivalLocal,
        );

        final departureAirport = _airportDraftForCode(
          fromCode,
          existingAirportsByIcao,
        );
        final arrivalAirport = _airportDraftForCode(
          toCode,
          existingAirportsByIcao,
        );

        final calculatedBlock = resolvedArrival
            .difference(departureDateTime)
            .inMinutes;
        final blockFromFile = _parseBlockHhMmToMinutes(get(indices.block));
        final blockMinutes = options.recalculateBlockTime
            ? calculatedBlock
            : (blockFromFile > 0 ? blockFromFile : calculatedBlock);

        if (get(indices.dhd).toUpperCase() == 'DH') {
          records.add(
            NormalizedPositioningRecord(
              progressOrdinal: progressOrdinal,
              departureAirport: departureAirport,
              arrivalAirport: arrivalAirport,
              departureDateTime: departureDateTime,
              arrivalDateTime: resolvedArrival,
              timeTotalMinutes: blockMinutes,
              notes: '',
              matchExistingByPositioningDateKey: true,
              overrideMatchedPositioning: options.overrideExistingData,
            ),
          );
          continue;
        }

        final rawTypeCode = _normalizeSouthwestTypeCode(get(indices.type));
        final mappedTypeCode = _resolveMappedSouthwestTypeCode(
          rawTypeCode: rawTypeCode,
          mappings: normalizedTypeMappings,
        );
        if (mappedTypeCode == null &&
            rawTypeCode.isEmpty &&
            options.missingAircraftTypePolicy ==
                SouthwestMissingAircraftTypePolicy.skipLines) {
          skipped += 1;
          continue;
        }
        final typeCode =
            mappedTypeCode ?? (rawTypeCode.isEmpty ? 'UNKNOWN' : rawTypeCode);
        final aircraftType = ImportedAircraftTypeDraft(
          code: typeCode,
          family: _southwestFamily(typeCode),
          longName: typeCode,
          manufacturer: '',
          category: AircraftCategory.landplane,
          engineType: EngineType.jet,
          mtow: 0,
          engineCount: 2,
          multiPilot: true,
          complex: true,
          efis: true,
          highPerformance: true,
        );
        final rawTail = get(indices.tail).toUpperCase();
        if (rawTail.isEmpty &&
            options.missingAircraftTailPolicy ==
                SouthwestMissingAircraftTailPolicy.skipLines) {
          skipped += 1;
          continue;
        }
        final aircraft = ImportedAircraftDraft(
          registration: rawTail.isEmpty ? typeCode : rawTail,
          mtow: null,
          isSimulator: false,
        );
        if (aircraft.registration.isEmpty) {
          skipped += 1;
          continue;
        }

        final depAirport = existingAirportsByIcao[_airportKey(fromCode)];
        final arrAirport = existingAirportsByIcao[_airportKey(toCode)];
        FlightCalculations? calculations;
        var distanceNm = 0;
        if (depAirport != null &&
            arrAirport != null &&
            _hasCoords(
              depAirport.latitude,
              depAirport.longitude,
              arrAirport.latitude,
              arrAirport.longitude,
            )) {
          calculations = FlightCalculations(
            latDep: depAirport.latitude,
            longDep: depAirport.longitude,
            latArr: arrAirport.latitude,
            longArr: arrAirport.longitude,
            depTimeEpochSeconds: _wallClockAsUtcEpochSeconds(departureDateTime),
            arrTimeEpochSeconds: _wallClockAsUtcEpochSeconds(resolvedArrival),
          );
          distanceNm = calculations.flightDistanceNm.round();
        }

        final takeoffCount = _parseInt(get(indices.takeoff));
        final landingCount = _parseInt(get(indices.landing));
        var takeoffsDay = takeoffCount;
        var takeoffsNight = 0;
        var landingsDay = landingCount;
        var landingsNight = 0;
        if (options.recalculateNightTime && calculations != null) {
          if (takeoffCount > 0) {
            takeoffsDay = calculations.dayTakeOff ? takeoffCount : 0;
            takeoffsNight = calculations.dayTakeOff ? 0 : takeoffCount;
          }
          if (landingCount > 0) {
            landingsDay = calculations.dayLanding ? landingCount : 0;
            landingsNight = calculations.dayLanding ? 0 : landingCount;
          }
        }

        final selfPosition = _normalizeSelfPosition(
          options.defaultSelfPosition,
        );
        final selfIsPic = selfPosition == CrewPosition.pic;
        final crewAssignments = <ImportedCrewAssignmentDraft>[
          ImportedCrewAssignmentDraft.self(
            position: selfPosition,
            createSelfIfMissing: false,
          ),
        ];
        final coPilot = _parseSouthwestCoPilot(get(indices.copilot));
        if (coPilot.name.isNotEmpty) {
          crewAssignments.add(
            ImportedCrewAssignmentDraft.crew(
              position: _oppositePosition(selfPosition),
              crew: ImportedCrewDraft(
                name: coPilot.name,
                notes:
                    options.addCopilotStaffNumberToNotes &&
                        (coPilot.staffNumber ?? '').isNotEmpty
                    ? 'Staff Number: ${coPilot.staffNumber}'
                    : '',
              ),
            ),
          );
        }
        if (!hasSelfCrew) {
          crewAssignments.removeWhere((assignment) => assignment.assignSelf);
        }

        var ifrMinutes = 0;
        if (options.recalculateIfrTime && blockMinutes > 0) {
          ifrMinutes = calculateIfrMinutes(
            totalMinutes: blockMinutes,
            percent: options.ifrPercent,
            subtractMinutes: options.ifrSubtractMinutes,
            minimumMinutes: options.ifrMinimumMinutes,
          );
        }

        records.add(
          NormalizedFlightRecord(
            progressOrdinal: progressOrdinal,
            departureAirport: departureAirport,
            arrivalAirport: arrivalAirport,
            aircraftType: aircraftType,
            aircraft: aircraft,
            departureDateTime: departureDateTime,
            arrivalDateTime: resolvedArrival,
            timePicMinutes: selfIsPic ? blockMinutes : 0,
            timePicusMinutes: 0,
            timeSicMinutes: selfIsPic ? 0 : blockMinutes,
            timeDualMinutes: 0,
            timeInstructorMinutes: 0,
            timeIfrMinutes: ifrMinutes,
            timeNightMinutes:
                options.recalculateNightTime && calculations != null
                ? calculations.nightTimeMinutes
                : 0,
            timeCrossCountryMinutes: options.recalculateCrossCountry
                ? (distanceNm >= options.crossCountryThresholdNm
                      ? blockMinutes
                      : 0)
                : 0,
            timeCustom1Minutes: 0,
            timeCustom2Minutes: 0,
            timeCustom3Minutes: 0,
            timeCustom4Minutes: 0,
            timeFlightMinutes: 0,
            timeBlockMinutes: blockMinutes,
            timeTotalBlockMinutes: blockMinutes,
            distanceNm: distanceNm,
            ifrApproaches: 0,
            takeoffsDay: takeoffsDay,
            takeoffsNight: takeoffsNight,
            landingsDay: landingsDay,
            landingsNight: landingsNight,
            pilotFunction: PilotFunctionLogic.fromTakeoffLanding(
              takeoffCount: takeoffCount,
              landingCount: landingCount,
            ),
            approachType: '',
            remarks: '',
            notes: _buildSouthwestNotes(
              flightNumber: get(indices.flight),
              includeFlightNumber: options.addFlightNumberToNotes,
            ),
            crewAssignments: crewAssignments,
            matchExistingByFlightDateKey: true,
            overrideMatchedFlight: options.overrideExistingData,
          ),
        );
      } on Object catch (_) {
        errors += 1;
      }
    }

    return NormalizedImportBatch(
      totalRows: rows.length - headerRowIndex - 1,
      records: records,
      entityOptions: ImportedEntityOptions(
        overrideAirportValues: options.overrideExistingData,
        overrideAircraftValues: options.overrideExistingData,
        overrideAircraftTypeValues: options.overrideExistingData,
        overrideCrewValues: options.overrideExistingData,
      ),
      skippedRows: skipped,
      errorRows: errors,
    );
  }
}

int _findHeaderRowIndex(List<List<String>> rows) {
  return rows.indexWhere(
    (row) =>
        row.isNotEmpty &&
        SimpleLogCsvSupport.clean(row.first).toUpperCase() == 'DATE',
  );
}

class _SouthwestHeaderIndices {
  _SouthwestHeaderIndices(List<String> header)
    : _index = <String, int>{
        for (var i = 0; i < header.length; i += 1)
          SimpleLogCsvSupport.clean(header[i]).toUpperCase(): i,
      };

  final Map<String, int> _index;

  int _read(String name) => _index[name.toUpperCase()] ?? -1;

  int get date => _read('DATE');
  int get flight => _read('Flight');
  int get dhd => _read('dhd');
  int get from => _read('From');
  int get depart => _read('Depart');
  int get to => _read('To');
  int get arrive => _read('Arrive');
  int get block => _read('Block');
  int get tail => _read('Tail_Number');
  int get type => _read('A_C_Type');
  int get takeoff => _read('TakeOff');
  int get landing => _read('Landing');
  int get copilot => _read('CoPilot');
}

String? _resolveMappedSouthwestTypeCode({
  required String rawTypeCode,
  required Map<String, String> mappings,
}) {
  if (mappings.isEmpty) {
    return null;
  }
  final normalizedRawType = _normalizeSouthwestTypeCode(rawTypeCode);
  final rawMappedValue = mappings[normalizedRawType] ?? '';
  final normalizedMappedValue = _normalizeSouthwestTypeCode(rawMappedValue);
  if (normalizedMappedValue.isEmpty) {
    return null;
  }
  return normalizedMappedValue;
}

String _normalizeSouthwestTypeCode(String value) {
  return value.trim().toUpperCase();
}

String _normalizeSouthwestAircraftRegistration(String value) {
  return value.trim().toUpperCase();
}

Map<String, String> _normalizeSouthwestTypeMappings(
  Map<String, String> mappings,
) {
  if (mappings.isEmpty) {
    return const <String, String>{};
  }
  return <String, String>{
    for (final entry in mappings.entries)
      _normalizeSouthwestTypeCode(entry.key): _normalizeSouthwestTypeCode(
        entry.value,
      ),
  };
}

ImportedAirportDraft _airportDraftForCode(
  String code,
  Map<String, Airport> existingAirportsByIcao,
) {
  final airport = existingAirportsByIcao[_airportKey(code)];
  return ImportedAirportDraft(
    icao: code,
    latitude: airport?.latitude ?? 0,
    longitude: airport?.longitude ?? 0,
    latitudeRaw: airport == null ? '' : airport.latitude.toString(),
    longitudeRaw: airport == null ? '' : airport.longitude.toString(),
  );
}

DateTime? _parseSouthwestLocalDateTime(String date, String time) {
  try {
    final d = DateFormat('yyyy-MM-dd').parseStrict(date.trim());
    final parts = time.trim().split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]) ?? -1;
    final minute = int.tryParse(parts[1]) ?? -1;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    // Keep this as a timezone-neutral wall-clock container so adding
    // a day for overnight legs is not affected by the host device timezone.
    return DateTime.utc(d.year, d.month, d.day, hour, minute);
  } on Object catch (_) {
    return null;
  }
}

int _parseBlockHhMmToMinutes(String value) {
  final digits = value.replaceAll(RegExp('[^0-9]'), '');
  if (digits.isEmpty) return 0;
  final raw = int.tryParse(digits) ?? 0;
  if (digits.length <= 2) return raw;
  final hours = raw ~/ 100;
  final mins = raw % 100;
  if (mins < 0 || mins > 59) return 0;
  return hours * 60 + mins;
}

int _parseInt(String value) => int.tryParse(value.trim()) ?? 0;

String _southwestFamily(String typeCode) {
  final clean = typeCode.trim().toUpperCase();
  if (clean.isEmpty) return 'UNKNOWN';
  final split = clean.split('-');
  return split.isEmpty ? clean : split.first;
}

_SouthwestCopilot _parseSouthwestCoPilot(String raw) {
  final clean = raw.trim();
  if (clean.isEmpty || clean.toLowerCase().contains('deadheading')) {
    return const _SouthwestCopilot(name: '', staffNumber: null);
  }
  final staffMatch = RegExp(r'\[(\d+)\]').firstMatch(clean);
  final staffNumber = staffMatch?.group(1);
  var name = clean.replaceAll(RegExp(r'\[[^\]]*\]'), '');
  name = name.replaceAll('*CKP*', ' ');
  name = name.replaceAll(RegExp(r'^(CA|CP|FO)\s+', caseSensitive: false), '');
  name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
  return _SouthwestCopilot(name: name, staffNumber: staffNumber);
}

String _buildSouthwestNotes({
  required String flightNumber,
  required bool includeFlightNumber,
}) {
  final lines = <String>[];
  if (includeFlightNumber && flightNumber.trim().isNotEmpty) {
    lines.add('Flight Number: ${flightNumber.trim()}');
  }
  return lines.join('\n');
}

CrewPosition _normalizeSelfPosition(CrewPosition value) {
  if (value == CrewPosition.pic || value == CrewPosition.sic) return value;
  return CrewPosition.sic;
}

CrewPosition _oppositePosition(CrewPosition selfPosition) {
  return selfPosition == CrewPosition.sic ? CrewPosition.pic : CrewPosition.sic;
}

bool _hasCoords(double latDep, double longDep, double latArr, double longArr) {
  return (latDep != 0 || longDep != 0) && (latArr != 0 || longArr != 0);
}

int _wallClockAsUtcEpochSeconds(DateTime dt) {
  return DateTime.utc(
        dt.year,
        dt.month,
        dt.day,
        dt.hour,
        dt.minute,
        dt.second,
        dt.millisecond,
        dt.microsecond,
      ).millisecondsSinceEpoch ~/
      1000;
}

String _airportKey(String icao) => icao.trim().toLowerCase();

DateTime _southwestCentralLocalToUtc(DateTime localDateTime) {
  _ensureSouthwestTimezoneInitialized();
  final central = _southwestCentralTimezone!;
  final zoned = tz.TZDateTime(
    central,
    localDateTime.year,
    localDateTime.month,
    localDateTime.day,
    localDateTime.hour,
    localDateTime.minute,
    localDateTime.second,
    localDateTime.millisecond,
    localDateTime.microsecond,
  );
  return zoned.toUtc();
}

tz.Location? _southwestCentralTimezone;
bool _southwestTimezoneInitialized = false;

void _ensureSouthwestTimezoneInitialized() {
  if (!_southwestTimezoneInitialized) {
    tz_data.initializeTimeZones();
    _southwestTimezoneInitialized = true;
  }
  _southwestCentralTimezone ??= tz.getLocation('America/Chicago');
}

class _SouthwestCopilot {
  const _SouthwestCopilot({required this.name, required this.staffNumber});

  final String name;
  final String? staffNumber;
}
