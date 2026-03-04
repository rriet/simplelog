import 'package:simplelog/core/flight/flight_calculations.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';

/// Parses LogTen Pro tab-separated exports into normalized import records.
class LogTenProTsvSourceParser {
  /// Creates a parser.
  const LogTenProTsvSourceParser();

  /// Parses a LogTen Pro tab-separated export into a normalized batch.
  NormalizedImportBatch parse(
    String content, {
    required Map<String, Airport> existingAirportsByIcao,
    required Map<String, Airport> existingAirportsByIata,
  }) {
    final rows = _parseTsv(content);
    if (rows.isEmpty) {
      return const NormalizedImportBatch(
        totalRows: 0,
        records: [],
        entityOptions: ImportedEntityOptions(
          overrideAirportValues: false,
          overrideAircraftValues: false,
          overrideAircraftTypeValues: false,
          overrideCrewValues: false,
        ),
      );
    }

    final header = rows.first
        .map((value) => value.trim())
        .toList(growable: false);
    final headerIndex = <String, int>{
      for (var i = 0; i < header.length; i += 1) header[i]: i,
    };
    final timeFormat = _detectTimeFormat(rows.skip(1), headerIndex);

    final records = <NormalizedImportRecord>[];
    var skipped = 0;
    var progressOrdinal = 0;

    for (var fileRowIndex = 1; fileRowIndex < rows.length; fileRowIndex += 1) {
      final row = rows[fileRowIndex];
      progressOrdinal += 1;
      final sourceLineNumber = fileRowIndex + 1;
      final data = _LogTenRow(
        values: row,
        headerIndex: headerIndex,
        lineNumber: sourceLineNumber,
      );
      final flightType = data.read('flight_type').trim();

      if (flightType.isEmpty) {
        final record = _buildFlightRecord(
          data,
          progressOrdinal: progressOrdinal,
          timeFormat: timeFormat,
          existingAirportsByIcao: existingAirportsByIcao,
          existingAirportsByIata: existingAirportsByIata,
        );
        if (record == null) {
          skipped += 1;
        } else {
          records.add(record);
        }
      } else if (flightType == '1') {
        final record = _buildPositioningRecord(
          data,
          progressOrdinal: progressOrdinal,
          timeFormat: timeFormat,
          existingAirportsByIcao: existingAirportsByIcao,
          existingAirportsByIata: existingAirportsByIata,
        );
        if (record == null) {
          skipped += 1;
        } else {
          records.add(record);
        }
      } else if (flightType == '3') {
        final record = _buildSimulatorRecord(
          data,
          progressOrdinal: progressOrdinal,
          timeFormat: timeFormat,
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
    );
  }

  NormalizedFlightRecord? _buildFlightRecord(
    _LogTenRow row, {
    required int progressOrdinal,
    required _LogTenTimeFormat timeFormat,
    required Map<String, Airport> existingAirportsByIcao,
    required Map<String, Airport> existingAirportsByIata,
  }) {
    final date = _parseDate(row.read('flight_flightDate'), row.lineNumber);
    final departureAirport = _resolveAirport(
      row.read('flight_from'),
      lineNumber: row.lineNumber,
      existingAirportsByIcao: existingAirportsByIcao,
      existingAirportsByIata: existingAirportsByIata,
    );
    final arrivalAirport = _resolveAirport(
      row.read('flight_to'),
      lineNumber: row.lineNumber,
      existingAirportsByIcao: existingAirportsByIcao,
      existingAirportsByIata: existingAirportsByIata,
    );
    final departureDateTime =
        _parseOptionalDateTime(
          date,
          row.read('flight_actualDepartureTime'),
          row.lineNumber,
        ) ??
        date;
    final arrivalDateTime = _parseOptionalDateTime(
      date,
      row.read('flight_actualArrivalTime'),
      row.lineNumber,
    );
    final takeOffDateTime = _parseOptionalDateTime(
      date,
      row.read('flight_takeoffTime'),
      row.lineNumber,
    );
    final landingDateTime = _parseOptionalDateTime(
      date,
      row.read('flight_landingTime'),
      row.lineNumber,
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

    final totalMinutes = _parseOptionalDuration(
      row.read('flight_totalTime'),
      timeFormat,
      row.lineNumber,
    );
    final blockMinutes = totalMinutes ?? 0;

    final aircraftType = _buildAircraftTypeDraft(row);
    final aircraft = _buildAircraftDraft(row, isSimulator: false);
    if (aircraft.registration.isEmpty && aircraftType.code.isEmpty) {
      return null;
    }

    final distanceNm = _parseDistanceNm(
      row.read('flight_distance'),
      lineNumber: row.lineNumber,
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
            row.read('flight_pic'),
            timeFormat,
            row.lineNumber,
          ) ??
          _parseOptionalDuration(
            row.read('flight_solo'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timePicusMinutes:
          _parseOptionalDuration(
            row.read('flight_p1us'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeSicMinutes:
          _parseOptionalDuration(
            row.read('flight_sic'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeDualMinutes:
          _parseOptionalDuration(
            row.read('flight_dualReceived'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeInstructorMinutes:
          _parseOptionalDuration(
            row.read('flight_dualGiven'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeIfrMinutes:
          _parseOptionalDuration(
            row.read('flight_actualInstrument'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeInstrumentMinutes:
          _parseOptionalDuration(
            row.read('flight_actualInstrument'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeSimulatedInstrumentMinutes:
          _parseOptionalDuration(
            row.read('flight_simulatedInstrument'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeNightMinutes:
          _parseOptionalDuration(
            row.read('flight_night'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeCrossCountryMinutes:
          _parseOptionalDuration(
            row.read('flight_crossCountry'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeCustom1Minutes:
          _parseOptionalDuration(
            row.read('flight_customTime1'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeCustom2Minutes:
          _parseOptionalDuration(
            row.read('flight_customTime2'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeCustom3Minutes:
          _parseOptionalDuration(
            row.read('flight_customTime3'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeCustom4Minutes:
          _parseOptionalDuration(
            row.read('flight_customTime4'),
            timeFormat,
            row.lineNumber,
          ) ??
          0,
      timeFlightMinutes: 0,
      timeBlockMinutes: blockMinutes,
      timeTotalBlockMinutes: blockMinutes,
      distanceNm: resolvedDistanceNm,
      ifrApproaches: 0,
      takeoffsDay: _parseOptionalInt(row.read('flight_dayTakeoffs')),
      takeoffsNight: _parseOptionalInt(row.read('flight_nightTakeoffs')),
      landingsDay: _parseOptionalInt(row.read('flight_dayLandings')),
      landingsNight: _parseOptionalInt(row.read('flight_nightLandings')),
      pilotFunction: 'PF',
      approachType: '',
      remarks: row.read('flight_remarks'),
      notes: _buildFlightNotes(row),
      crewAssignments: _buildCrewAssignments(row),
    );
  }

  NormalizedPositioningRecord? _buildPositioningRecord(
    _LogTenRow row, {
    required int progressOrdinal,
    required _LogTenTimeFormat timeFormat,
    required Map<String, Airport> existingAirportsByIcao,
    required Map<String, Airport> existingAirportsByIata,
  }) {
    final date = _parseDate(row.read('flight_flightDate'), row.lineNumber);
    final departureAirport = _resolveAirport(
      row.read('flight_from'),
      lineNumber: row.lineNumber,
      existingAirportsByIcao: existingAirportsByIcao,
      existingAirportsByIata: existingAirportsByIata,
    );
    final arrivalAirport = _resolveAirport(
      row.read('flight_to'),
      lineNumber: row.lineNumber,
      existingAirportsByIcao: existingAirportsByIcao,
      existingAirportsByIata: existingAirportsByIata,
    );
    final departureDateTime =
        _parseOptionalDateTime(
          date,
          row.read('flight_actualDepartureTime'),
          row.lineNumber,
        ) ??
        date;
    final arrivalDateTime = _resolveEndAfterStart(
      start: departureDateTime,
      end: _parseOptionalDateTime(
        date,
        row.read('flight_actualArrivalTime'),
        row.lineNumber,
      ),
    );
    final totalMinutes =
        _parseOptionalDuration(
          row.read('flight_totalTime'),
          timeFormat,
          row.lineNumber,
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
  }) {
    final date = _parseDate(row.read('flight_flightDate'), row.lineNumber);
    final total = _parseOptionalDuration(
      row.read('flight_simulator'),
      timeFormat,
      row.lineNumber,
    );
    if (total == null || total <= 0) {
      return null;
    }
    final aircraftType = _buildAircraftTypeDraft(row);
    if (aircraftType.code.isEmpty) {
      throw FormatException(
        'Line ${row.lineNumber}: simulator row is missing aircraftType_type.',
      );
    }
    final aircraft = _buildAircraftDraft(row, isSimulator: true);
    if (aircraft.registration.isEmpty) {
      throw FormatException(
        'Line ${row.lineNumber}: simulator row is missing aircraft_aircraftID.',
      );
    }
    final startDateTime =
        _parseOptionalDateTime(
          date,
          row.read('flight_actualDepartureTime'),
          row.lineNumber,
        ) ??
        date;
    return NormalizedSimulatorRecord(
      progressOrdinal: progressOrdinal,
      aircraftType: aircraftType,
      aircraft: aircraft,
      startDateTime: startDateTime,
      endDateTime: startDateTime.add(Duration(minutes: total)),
      timeTotal: total,
      remarks: row.read('flight_remarks'),
      notes: _buildFlightNotes(row),
      crewAssignments: _buildCrewAssignments(row),
    );
  }

  ImportedAircraftTypeDraft _buildAircraftTypeDraft(_LogTenRow row) {
    final code = row.read('aircraftType_type').trim().toUpperCase();
    final hasWaterOps =
        _parseOptionalInt(row.read('flight_waterLandings')) > 0 ||
        _parseOptionalInt(row.read('flight_waterTakeoffs')) > 0;
    return ImportedAircraftTypeDraft(
      code: code,
      family: code,
      longName: row.read('aircraftType_model').trim(),
      manufacturer: row.read('aircraftType_make').trim(),
      category: _mapCategory(
        row.read('aircraftType_selectedCategory'),
        hasWaterOps: hasWaterOps,
        lineNumber: row.lineNumber,
      ),
      engineType: _mapEngineType(
        row.read('aircraftType_selectedEngineType'),
        lineNumber: row.lineNumber,
      ),
      mtow: 0,
      engineCount: 1,
      multiPilot:
          _parseOptionalDuration(
            row.read('flight_multiPilot'),
            _LogTenTimeFormat.hhMm,
            row.lineNumber,
            allowAltFormat: true,
          ) !=
          null,
      complex: _parseBool(row.read('aircraft_complex')),
      efis: _parseBool(row.read('aircraft_efis')),
      highPerformance: _parseBool(row.read('aircraft_highPerformance')),
    );
  }

  ImportedAircraftDraft _buildAircraftDraft(
    _LogTenRow row, {
    required bool isSimulator,
  }) {
    return ImportedAircraftDraft(
      registration: row.read('aircraft_aircraftID').trim().toUpperCase(),
      mtow: _parseOptionalInt(row.read('aircraft_weight')),
      isSimulator: isSimulator,
      notes: row.read('aircraft_notes').trim(),
    );
  }

  List<ImportedCrewAssignmentDraft> _buildCrewAssignments(_LogTenRow row) {
    final assignments = <ImportedCrewAssignmentDraft>[];
    final seen = <String>{};

    void add(String column, CrewPosition position) {
      final name = row.read(column).trim();
      if (name.isEmpty) return;
      final key = '${name.toLowerCase()}|${position.name}';
      if (!seen.add(key)) return;
      assignments.add(
        ImportedCrewAssignmentDraft.crew(
          position: position,
          crew: ImportedCrewDraft(name: name),
        ),
      );
    }

    add('flight_selectedCrewPIC', CrewPosition.pic);
    add('flight_selectedCrewSIC', CrewPosition.sic);
    add('flight_selectedCrewRelief', CrewPosition.relief);
    add('flight_selectedCrewRelief2', CrewPosition.relief);
    add('flight_selectedCrewRelief3', CrewPosition.relief);
    add('flight_selectedCrewRelief4', CrewPosition.relief);
    add('flight_selectedCrewFlightEngineer', CrewPosition.other);
    add('flight_selectedCrewInstructor', CrewPosition.instructor);
    add('flight_selectedCrewStudent', CrewPosition.trainee);
    add('flight_selectedCrewObserver', CrewPosition.observer);
    add('flight_selectedCrewObserver2', CrewPosition.observer);
    add('flight_selectedCrewPurser', CrewPosition.cabinCrew);
    add('flight_selectedCrewFlightAttendant', CrewPosition.cabinCrew);
    add('flight_selectedCrewFlightAttendant2', CrewPosition.cabinCrew);
    add('flight_selectedCrewFlightAttendant3', CrewPosition.cabinCrew);
    add('flight_selectedCrewFlightAttendant4', CrewPosition.cabinCrew);
    add('flight_selectedCrewCommander', CrewPosition.pic);
    add('flight_selectedCrewCustom1', CrewPosition.other);
    add('flight_selectedCrewCustom2', CrewPosition.other);
    add('flight_selectedCrewCustom3', CrewPosition.other);
    add('flight_selectedCrewCustom4', CrewPosition.other);
    add('flight_selectedCrewCustom5', CrewPosition.other);

    return assignments;
  }

  ImportedAirportDraft _resolveAirport(
    String rawCode, {
    required int lineNumber,
    required Map<String, Airport> existingAirportsByIcao,
    required Map<String, Airport> existingAirportsByIata,
  }) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      throw FormatException('Line $lineNumber: airport code is empty.');
    }
    if (code.length == 4) {
      final existing = existingAirportsByIcao[code.toLowerCase()];
      if (existing == null) {
        return ImportedAirportDraft(icao: code);
      }
      return _airportDraftFromAirport(existing);
    }
    if (code.length == 3) {
      final existing = existingAirportsByIata[code.toLowerCase()];
      if (existing == null) {
        throw FormatException(
          'Line $lineNumber: IATA airport "$code" does not exist '
          'in the database.',
        );
      }
      return _airportDraftFromAirport(existing);
    }
    throw FormatException(
      'Line $lineNumber: invalid airport code "$code". '
      'Expected ICAO (4) or IATA (3).',
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
    final notes = <String>[];
    final flightNumber = row.read('flight_flightNumber').trim();
    if (flightNumber.isNotEmpty) {
      notes.add('Flight Number: $flightNumber');
    }
    return notes.join('\n');
  }

  DateTime _parseDate(String value, int lineNumber) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Line $lineNumber: missing flight_flightDate.');
    }
    final parts = trimmed.split('-');
    if (parts.length != 3) {
      throw FormatException('Line $lineNumber: invalid date "$trimmed".');
    }
    return DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  DateTime? _parseOptionalDateTime(
    DateTime date,
    String value,
    int lineNumber,
  ) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split(':');
    if (parts.length < 2 || parts.length > 3) {
      throw FormatException('Line $lineNumber: invalid time "$trimmed".');
    }
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final second = parts.length == 3 ? int.parse(parts[2]) : 0;
    return DateTime.utc(date.year, date.month, date.day, hour, minute, second);
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
    int lineNumber, {
    bool allowAltFormat = false,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains(':')) {
      if (format != _LogTenTimeFormat.hhMm && !allowAltFormat) {
        throw FormatException(
          'Line $lineNumber: mixed duration formats are not supported.',
        );
      }
      final parts = trimmed.split(':');
      if (parts.length != 2) {
        throw FormatException('Line $lineNumber: invalid duration "$trimmed".');
      }
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      return (hours * 60) + minutes;
    }

    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      throw FormatException('Line $lineNumber: invalid duration "$trimmed".');
    }
    return (parsed * 60).round();
  }

  int? _parseDistanceNm(String value, {required int lineNumber}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      throw FormatException('Line $lineNumber: invalid distance "$trimmed".');
    }
    return parsed.round();
  }

  int _parseOptionalInt(String value) {
    final trimmed = value.trim();
    return int.tryParse(trimmed) ?? 0;
  }

  bool _parseBool(String value) {
    final trimmed = value.trim().toLowerCase();
    return trimmed == '1' || trimmed == 'true' || trimmed == 'yes';
  }

  EngineType _mapEngineType(String value, {required int lineNumber}) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      '' => EngineType.unknown,
      'jet' => EngineType.jet,
      'reciprocating' => EngineType.piston,
      'turboprop' => EngineType.turboprop,
      'turbo prop' => EngineType.turboprop,
      'electric' => EngineType.electric,
      _ => throw FormatException(
        'Line $lineNumber: unsupported engine type "$value".',
      ),
    };
  }

  AircraftCategory _mapCategory(
    String value, {
    required bool hasWaterOps,
    required int lineNumber,
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
      _ => throw FormatException(
        'Line $lineNumber: unsupported aircraft category "$value".',
      ),
    };
  }

  _LogTenTimeFormat _detectTimeFormat(
    Iterable<List<String>> rows,
    Map<String, int> headerIndex,
  ) {
    const durationColumns = <String>[
      'flight_totalTime',
      'flight_pic',
      'flight_sic',
      'flight_night',
      'flight_crossCountry',
      'flight_actualInstrument',
      'flight_simulatedInstrument',
      'flight_dualReceived',
      'flight_dualGiven',
      'flight_simulator',
      'flight_p1us',
      'flight_customTime1',
      'flight_customTime2',
      'flight_customTime3',
      'flight_customTime4',
    ];
    var sawHhMm = false;
    var sawDecimal = false;

    for (final row in rows) {
      for (final column in durationColumns) {
        final index = headerIndex[column];
        if (index == null || index >= row.length) continue;
        final value = row[index].trim();
        if (value.isEmpty) continue;
        if (value.contains(':')) {
          sawHhMm = true;
        } else {
          sawDecimal = true;
        }
      }
    }

    if (sawHhMm && sawDecimal) {
      throw const FormatException(
        'LogTen Pro export mixes HH:MM and decimal duration formats.',
      );
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
  });

  final List<String> values;
  final Map<String, int> headerIndex;
  final int lineNumber;

  String read(String column) {
    final index = headerIndex[column];
    if (index == null || index >= values.length) return '';
    return values[index].trim();
  }
}

enum _LogTenTimeFormat { hhMm, decimal }
