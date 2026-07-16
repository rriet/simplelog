import 'package:simplelog/core/flight/flight_calculations.dart';
import 'package:simplelog/core/flight/pilot_function_logic.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/import/foreflight_import_options.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/simplelog_csv_support.dart';
import 'package:simplelog/data/import/wader_import_models.dart';

/// Parses ForeFlight's two-table CSV logbook export.
class ForeFlightCsvSourceParser {
  /// Creates a ForeFlight parser.
  const ForeFlightCsvSourceParser();

  /// Whether [content] contains the required ForeFlight table markers.
  bool recognizes(String content) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    return _tableHeaderIndex(rows, 'AircraftID', 'TypeCode') >= 0 &&
        _tableHeaderIndex(rows, 'Date', 'AircraftID') >= 0 &&
        rows.any(
          (row) =>
              row.isNotEmpty &&
              _clean(row.first).startsWith('ForeFlight Logbook Import'),
        );
  }

  /// Validates source rows and returns issues supported by the shared reviewer.
  List<WaderImportIssue> validate(
    String content, {
    required ForeFlightImportOptions options,
    Set<String> existingAirportCodes = const <String>{},
  }) {
    final source = _readSource(content);
    final issues = <WaderImportIssue>[];
    for (final flight in source.flights) {
      if (options.review.ignoredLines.contains(flight.lineNumber)) continue;
      final date = _resolved(
        options.review,
        flight,
        WaderFieldAssociation.date,
        'Date',
      );
      final tail = _resolved(
        options.review,
        flight,
        WaderFieldAssociation.aircraftTail,
        'AircraftID',
      ).toUpperCase();
      final aircraft = source.aircraft[tail];
      final type = _resolved(
        options.review,
        flight,
        WaderFieldAssociation.aircraftType,
        'TypeCode',
        fallback: aircraft?.typeCode ?? '',
      ).toUpperCase();
      final simulated = _duration(flight.read('SimulatedFlight')) > 0;
      if (_date(date) == null) {
        issues.add(
          _issue(
            flight,
            WaderFieldAssociation.date,
            date,
            'A valid flight date is required.',
          ),
        );
      }
      if (tail.isEmpty) {
        issues.add(
          _issue(
            flight,
            WaderFieldAssociation.aircraftTail,
            tail,
            'Aircraft ID is required.',
          ),
        );
      }
      if (type.isEmpty) {
        issues.add(
          _issue(
            flight,
            WaderFieldAssociation.aircraftType,
            type,
            'Aircraft type is required.',
          ),
        );
      }
      if (!simulated) {
        _validateAirport(
          issues,
          flight: flight,
          association: WaderFieldAssociation.departureAirport,
          field: 'From',
          options: options,
          existingAirportCodes: existingAirportCodes,
        );
        _validateAirport(
          issues,
          flight: flight,
          association: WaderFieldAssociation.arrivalAirport,
          field: 'To',
          options: options,
          existingAirportCodes: existingAirportCodes,
        );
      }
      final total = _duration(flight.read('TotalTime'));
      final out = _clock(flight.read('TimeOut'));
      final timeIn = _clock(flight.read('TimeIn'));
      if (!simulated && total <= 0 && (out == null || timeIn == null)) {
        issues.add(
          _issue(
            flight,
            WaderFieldAssociation.totalTime,
            flight.read('TotalTime'),
            'Total time or both Time Out and Time In are required.',
          ),
        );
      }
    }
    return issues;
  }

  /// Converts a ForeFlight export to normalized persistence records.
  NormalizedImportBatch parse(
    String content, {
    required ForeFlightImportOptions options,
    Map<String, Airport> existingAirportsByCode = const <String, Airport>{},
  }) {
    final source = _readSource(content);
    final records = <NormalizedImportRecord>[];
    var skipped = 0;
    for (var i = 0; i < source.flights.length; i += 1) {
      final flight = source.flights[i];
      if (options.review.ignoredLines.contains(flight.lineNumber)) {
        skipped += 1;
        continue;
      }
      records.add(
        _record(
          source,
          flight,
          i + 1,
          options,
          existingAirportsByCode,
        ),
      );
    }
    final unified = options.unified;
    return NormalizedImportBatch(
      totalRows: source.flights.length,
      records: records,
      skippedRows: skipped,
      entityOptions: ImportedEntityOptions(
        overrideAirportValues: unified.overrideAirportOnConflict,
        overrideAircraftValues: unified.overrideAircraftOnConflict,
        overrideAircraftTypeValues: unified.overrideTypeOnConflict,
        overrideCrewValues: false,
      ),
    );
  }

  NormalizedImportRecord _record(
    _ForeFlightSource source,
    _ForeFlightRow row,
    int ordinal,
    ForeFlightImportOptions options,
    Map<String, Airport> existingAirportsByCode,
  ) {
    final review = options.review;
    final baseDate = _date(
      _resolved(review, row, WaderFieldAssociation.date, 'Date'),
    )!;
    final tail = _resolved(
      review,
      row,
      WaderFieldAssociation.aircraftTail,
      'AircraftID',
    ).toUpperCase();
    final definition = source.aircraft[tail];
    final typeCode = _resolved(
      review,
      row,
      WaderFieldAssociation.aircraftType,
      'TypeCode',
      fallback: definition?.typeCode ?? tail,
    ).toUpperCase();
    final simulatedMinutes = _duration(row.read('SimulatedFlight'));
    final isSimulator = simulatedMinutes > 0;
    final aircraftType = _aircraftType(definition, typeCode);
    final aircraft = ImportedAircraftDraft(
      registration: tail,
      mtow: null,
      isSimulator: isSimulator,
      notes: definition == null
          ? ''
          : '${definition.make} ${definition.model}'.trim(),
    );
    final start = _dateTime(baseDate, row.read('TimeOut')) ?? baseDate;
    final suppliedTotal = _duration(
      _resolved(review, row, WaderFieldAssociation.totalTime, 'TotalTime'),
    );
    if (isSimulator) {
      final duration = simulatedMinutes > 0 ? simulatedMinutes : suppliedTotal;
      return NormalizedSimulatorRecord(
        progressOrdinal: ordinal,
        aircraftType: aircraftType,
        aircraft: aircraft,
        startDateTime: start,
        endDateTime: start.add(Duration(minutes: duration)),
        timeTotal: duration,
        remarks: row.read('PilotComments'),
        notes: row.read('InstructorComments'),
        crewAssignments: _crew(row),
      );
    }
    final arrival =
        _dateTimeAfter(baseDate, start, row.read('TimeIn')) ??
        start.add(Duration(minutes: suppliedTotal));
    final timelineTotal = arrival.difference(start).inMinutes;
    final total = options.unified.recalculateTotalTime && timelineTotal > 0
        ? timelineTotal
        : suppliedTotal > 0
        ? suppliedTotal
        : timelineTotal;
    final distance = double.tryParse(row.read('Distance'))?.round() ?? 0;
    final dayTakeoffs = _integer(row.read('DayTakeoffs'));
    final nightTakeoffs = _integer(row.read('NightTakeoffs'));
    final dayLandings = _integer(row.read('DayLandingsFullStop'));
    final nightLandings = _integer(row.read('NightLandingsFullStop'));
    final departureCode = _resolved(
      review,
      row,
      WaderFieldAssociation.departureAirport,
      'From',
    ).toUpperCase();
    final arrivalCode = _resolved(
      review,
      row,
      WaderFieldAssociation.arrivalAirport,
      'To',
    ).toUpperCase();
    final calculations = _calculations(
      departure: existingAirportsByCode[departureCode],
      arrival: existingAirportsByCode[arrivalCode],
      takeoff: _dateTimeAfter(baseDate, start, row.read('TimeOff')) ?? start,
      landing: _dateTimeAfter(baseDate, start, row.read('TimeOn')) ?? arrival,
    );
    var resolvedDayTakeoffs = dayTakeoffs;
    var resolvedNightTakeoffs = nightTakeoffs;
    var resolvedDayLandings = dayLandings;
    var resolvedNightLandings = nightLandings;
    if (options.unified.recalculateTakeoffLanding && calculations != null) {
      final totalTakeoffs = dayTakeoffs + nightTakeoffs;
      final totalLandings = dayLandings + nightLandings;
      resolvedDayTakeoffs = calculations.dayTakeOff ? totalTakeoffs : 0;
      resolvedNightTakeoffs = calculations.dayTakeOff ? 0 : totalTakeoffs;
      resolvedDayLandings = calculations.dayLanding ? totalLandings : 0;
      resolvedNightLandings = calculations.dayLanding ? 0 : totalLandings;
    }
    return NormalizedFlightRecord(
      progressOrdinal: ordinal,
      departureAirport: ImportedAirportDraft(icao: departureCode),
      arrivalAirport: ImportedAirportDraft(icao: arrivalCode),
      aircraftType: aircraftType,
      aircraft: aircraft,
      departureDateTime: start,
      takeOffDateTime: _dateTimeAfter(baseDate, start, row.read('TimeOff')),
      landingDateTime: _dateTimeAfter(baseDate, start, row.read('TimeOn')),
      arrivalDateTime: arrival,
      timePicMinutes: _duration(row.read('PIC')),
      timePicusMinutes: _duration(row.read('PICUS')),
      timeSicMinutes: _duration(row.read('SIC')),
      timeDualMinutes: _duration(row.read('DualReceived')),
      timeInstructorMinutes: _duration(row.read('DualGiven')),
      timeIfrMinutes: options.unified.recalculateIfrTime
          ? total
          : _duration(row.read('IFR')),
      timeNightMinutes:
          options.unified.recalculateNightTime && calculations != null
          ? calculations.nightTimeMinutes
          : _duration(row.read('Night')),
      timeCrossCountryMinutes: options.unified.recalculateCrossCountry
          ? (distance >= 50 ? total : 0)
          : _duration(row.read('CrossCountry')),
      timeCustom1Minutes: _duration(row.read('ActualInstrument')),
      timeCustom2Minutes: _duration(row.read('SimulatedInstrument')),
      timeCustom3Minutes: 0,
      timeCustom4Minutes: 0,
      timeFlightMinutes: total,
      timeBlockMinutes: total,
      timeTotalBlockMinutes: total,
      distanceNm: distance,
      ifrApproaches: _approaches(row),
      takeoffsDay: resolvedDayTakeoffs,
      takeoffsNight: resolvedNightTakeoffs,
      landingsDay: resolvedDayLandings,
      landingsNight: resolvedNightLandings,
      pilotFunction: PilotFunctionLogic.canonicalize(
        row.read('PilotComments').replaceAll('"', ''),
        takeoffCount: dayTakeoffs + nightTakeoffs,
        landingCount: dayLandings + nightLandings,
      ),
      approachType: _approachText(row),
      remarks: row.read('PilotComments'),
      notes: [
        row.read('Route'),
        row.read('InstructorComments'),
      ].where((v) => v.isNotEmpty).join(' — '),
      crewAssignments: _crew(row),
    );
  }

  FlightCalculations? _calculations({
    required Airport? departure,
    required Airport? arrival,
    required DateTime takeoff,
    required DateTime landing,
  }) {
    if (departure == null || arrival == null || !landing.isAfter(takeoff)) {
      return null;
    }
    return FlightCalculations(
      latDep: departure.latitude,
      longDep: departure.longitude,
      latArr: arrival.latitude,
      longArr: arrival.longitude,
      depTimeEpochSeconds: takeoff.millisecondsSinceEpoch ~/ 1000,
      arrTimeEpochSeconds: landing.millisecondsSinceEpoch ~/ 1000,
    );
  }

  ImportedAircraftTypeDraft _aircraftType(
    _ForeFlightAircraft? source,
    String code,
  ) {
    final className = source?.aircraftClass.toLowerCase() ?? '';
    final category = className.contains('helicopter')
        ? AircraftCategory.helicopter
        : className.contains('sea')
        ? AircraftCategory.seaplane
        : AircraftCategory.landplane;
    final engineText = source?.engineType.toLowerCase() ?? '';
    final engine = engineText.contains('piston')
        ? EngineType.piston
        : engineText.contains('turboprop')
        ? EngineType.turboprop
        : engineText.contains('jet') || engineText.contains('fan')
        ? EngineType.jet
        : EngineType.unknown;
    final multi = className.contains('multi_engine');
    return ImportedAircraftTypeDraft(
      code: code,
      family: code,
      longName: source?.model.isNotEmpty == true ? source!.model : code,
      manufacturer: source?.make ?? '',
      category: category,
      engineType: engine,
      mtow: 0,
      engineCount: multi ? 2 : 1,
      multiPilot: false,
      complex: source?.complex ?? false,
      efis: source?.taa ?? false,
      highPerformance: source?.highPerformance ?? false,
    );
  }

  List<ImportedCrewAssignmentDraft> _crew(_ForeFlightRow row) {
    final position = _duration(row.read('PIC')) > 0
        ? CrewPosition.pic
        : _duration(row.read('SIC')) > 0
        ? CrewPosition.sic
        : CrewPosition.unknown;
    return <ImportedCrewAssignmentDraft>[
      ImportedCrewAssignmentDraft.self(
        position: position,
        createSelfIfMissing: true,
      ),
    ];
  }

  void _validateAirport(
    List<WaderImportIssue> issues, {
    required _ForeFlightRow flight,
    required WaderFieldAssociation association,
    required String field,
    required ForeFlightImportOptions options,
    required Set<String> existingAirportCodes,
  }) {
    final value = _resolved(
      options.review,
      flight,
      association,
      field,
    ).toUpperCase();
    if (value.isEmpty || !RegExp(r'^[A-Z0-9]{3,4}$').hasMatch(value)) {
      issues.add(
        _issue(flight, association, value, 'A valid airport code is required.'),
      );
    } else if (!existingAirportCodes.contains(value)) {
      issues.add(
        _issue(
          flight,
          association,
          value,
          'Airport $value does not exist in the database.',
        ),
      );
    }
  }

  WaderImportIssue _issue(
    _ForeFlightRow row,
    WaderFieldAssociation field,
    String value,
    String reason,
  ) {
    return WaderImportIssue(
      lineNumber: row.lineNumber,
      association: field,
      currentValue: value,
      reason: reason,
    );
  }

  _ForeFlightSource _readSource(String content) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    final aircraftHeader = _tableHeaderIndex(rows, 'AircraftID', 'TypeCode');
    final flightHeader = _tableHeaderIndex(rows, 'Date', 'AircraftID');
    if (aircraftHeader < 0 ||
        flightHeader < 0 ||
        flightHeader <= aircraftHeader) {
      throw const FormatException('Invalid ForeFlight CSV tables.');
    }
    final aircraft = <String, _ForeFlightAircraft>{};
    for (var i = aircraftHeader + 1; i < flightHeader - 1; i += 1) {
      final row = _ForeFlightRow.from(rows[aircraftHeader], rows[i], i + 1);
      final id = row.read('AircraftID').toUpperCase();
      if (id.isEmpty) continue;
      aircraft[id] = _ForeFlightAircraft(
        typeCode: row.read('TypeCode').toUpperCase(),
        make: row.read('Make'),
        model: row.read('Model'),
        engineType: row.read('EngineType'),
        aircraftClass: row.read('aircraftClass (FAA)'),
        complex: _boolean(row.read('complexAircraft (FAA)')),
        taa: _boolean(row.read('taa (FAA)')),
        highPerformance: _boolean(row.read('highPerformance (FAA)')),
      );
    }
    final flights = <_ForeFlightRow>[];
    for (var i = flightHeader + 1; i < rows.length; i += 1) {
      final row = _ForeFlightRow.from(rows[flightHeader], rows[i], i + 1);
      if (row.read('Date').isNotEmpty || row.read('AircraftID').isNotEmpty) {
        flights.add(row);
      }
    }
    return _ForeFlightSource(aircraft: aircraft, flights: flights);
  }

  static int _tableHeaderIndex(
    List<List<String>> rows,
    String first,
    String second,
  ) {
    return rows.indexWhere(
      (row) =>
          row.length > 1 && _clean(row[0]) == first && _clean(row[1]) == second,
    );
  }

  static String _clean(String value) => value.replaceAll('\ufeff', '').trim();
  static bool _boolean(String value) => value.trim().toUpperCase() == 'TRUE';
  static int _integer(String value) =>
      double.tryParse(value.trim())?.round() ?? 0;
  static int _duration(String value) {
    final text = value.trim();
    if (text.isEmpty) return 0;
    final decimal = double.tryParse(text);
    if (decimal != null) return (decimal * 60).round();
    final parts = text.split(':');
    if (parts.length == 2) {
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      if (hours != null && minutes != null) return hours * 60 + minutes;
    }
    return 0;
  }

  static DateTime? _date(String value) {
    final text = value.trim();
    final iso = DateTime.tryParse(text);
    if (iso != null) return DateTime.utc(iso.year, iso.month, iso.day);
    final parts = text.split(RegExp('[/.-]'));
    if (parts.length != 3) return null;
    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    final c = int.tryParse(parts[2]);
    if (a == null || b == null || c == null) return null;
    final year = a > 31
        ? a
        : c < 100
        ? 2000 + c
        : c;
    final month = a > 31 ? b : a;
    final day = a > 31 ? c : b;
    return DateTime.utc(year, month, day);
  }

  static int? _clock(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    final parts = text.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null && hour < 24 && minute < 60) {
        return hour * 60 + minute;
      }
    }
    final decimal = double.tryParse(text);
    return decimal == null ? null : (decimal * 60).round();
  }

  static DateTime? _dateTime(DateTime date, String value) {
    final minutes = _clock(value);
    return minutes == null ? null : date.add(Duration(minutes: minutes));
  }

  static DateTime? _dateTimeAfter(DateTime date, DateTime start, String value) {
    var result = _dateTime(date, value);
    if (result != null && result.isBefore(start)) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  static String _resolved(
    WaderImportReviewOptions review,
    _ForeFlightRow row,
    WaderFieldAssociation association,
    String field, {
    String fallback = '',
  }) {
    return review.valueOverrides[row.lineNumber]?[association]
                ?.trim()
                .isNotEmpty ==
            true
        ? review.valueOverrides[row.lineNumber]![association]!.trim()
        : row.read(field).isNotEmpty
        ? row.read(field)
        : fallback;
  }

  static int _approaches(_ForeFlightRow row) {
    var total = 0;
    for (var i = 1; i <= 6; i += 1) {
      final value = row.read('Approach$i');
      if (value.isEmpty) continue;
      total += int.tryParse(value.split(';').first) ?? 1;
    }
    return total;
  }

  static String _approachText(_ForeFlightRow row) => [
    for (var i = 1; i <= 6; i += 1) row.read('Approach$i'),
  ].where((v) => v.isNotEmpty).join(' | ');
}

class _ForeFlightSource {
  const _ForeFlightSource({required this.aircraft, required this.flights});
  final Map<String, _ForeFlightAircraft> aircraft;
  final List<_ForeFlightRow> flights;
}

class _ForeFlightAircraft {
  const _ForeFlightAircraft({
    required this.typeCode,
    required this.make,
    required this.model,
    required this.engineType,
    required this.aircraftClass,
    required this.complex,
    required this.taa,
    required this.highPerformance,
  });
  final String typeCode;
  final String make;
  final String model;
  final String engineType;
  final String aircraftClass;
  final bool complex;
  final bool taa;
  final bool highPerformance;
}

class _ForeFlightRow {
  const _ForeFlightRow(this.values, this.lineNumber);
  factory _ForeFlightRow.from(
    List<String> header,
    List<String> row,
    int lineNumber,
  ) {
    return _ForeFlightRow(<String, String>{
      for (var i = 0; i < header.length; i += 1)
        _clean(header[i]): i < row.length ? _clean(row[i]) : '',
    }, lineNumber);
  }
  final Map<String, String> values;
  final int lineNumber;
  String read(String field) => values[field] ?? '';
  static String _clean(String value) => value.replaceAll('\ufeff', '').trim();
}
