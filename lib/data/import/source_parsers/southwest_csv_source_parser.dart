import 'package:intl/intl.dart';
import 'package:simplelog/core/flight/flight_calculations.dart';
import 'package:simplelog/core/flight/pilot_function_logic.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/simplelog_csv_support.dart';
import 'package:simplelog/data/import/southwest_import_options.dart';

/// Parses Southwest CSV exports into normalized import records.
class SouthwestCsvSourceParser {
  /// Creates a parser.
  const SouthwestCsvSourceParser();

  /// Parses Southwest CSV content into a normalized batch.
  NormalizedImportBatch parse(
    String content, {
    SouthwestImportOptions options = const SouthwestImportOptions(),
    Map<String, Airport> existingAirportsByIcao = const {},
    bool hasSelfCrew = false,
  }) {
    final rows = SimpleLogCsvSupport.parseCsv(content);
    final headerRowIndex = rows.indexWhere(
      (row) =>
          row.isNotEmpty &&
          SimpleLogCsvSupport.clean(row.first).toUpperCase() == 'DATE',
    );
    if (headerRowIndex < 0) {
      throw const FormatException('Southwest CSV header not found.');
    }

    final header = rows[headerRowIndex];
    final index = <String, int>{};
    for (var i = 0; i < header.length; i += 1) {
      index[SimpleLogCsvSupport.clean(header[i]).toUpperCase()] = i;
    }

    int readIndex(String name) => index[name.toUpperCase()] ?? -1;

    final idxDate = readIndex('DATE');
    final idxFlight = readIndex('Flight');
    final idxDhd = readIndex('dhd');
    final idxFrom = readIndex('From');
    final idxDepart = readIndex('Depart');
    final idxTo = readIndex('To');
    final idxArrive = readIndex('Arrive');
    final idxBlock = readIndex('Block');
    final idxTail = readIndex('Tail_Number');
    final idxType = readIndex('A_C_Type');
    final idxTakeoff = readIndex('TakeOff');
    final idxLanding = readIndex('Landing');
    final idxCopilot = readIndex('CoPilot');

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

      try {
        String get(int idx) =>
            idx >= 0 && idx < row.length ? row[idx].trim() : '';

        final dateText = get(idxDate);
        final fromCode = get(idxFrom).toUpperCase();
        final toCode = get(idxTo).toUpperCase();
        final departText = get(idxDepart);
        final arriveText = get(idxArrive);
        if (dateText.isEmpty ||
            fromCode.isEmpty ||
            toCode.isEmpty ||
            departText.isEmpty ||
            arriveText.isEmpty) {
          skipped += 1;
          continue;
        }

        final departureDateTime = _parseSouthwestDateTime(dateText, departText);
        final arrivalDateTime = _parseSouthwestDateTime(dateText, arriveText);
        if (departureDateTime == null || arrivalDateTime == null) {
          skipped += 1;
          continue;
        }
        var resolvedArrival = arrivalDateTime;
        if (resolvedArrival.isBefore(departureDateTime)) {
          resolvedArrival = resolvedArrival.add(const Duration(days: 1));
        }

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
        final blockFromFile = _parseBlockHhMmToMinutes(get(idxBlock));
        final blockMinutes = options.recalculateBlockTime
            ? calculatedBlock
            : (blockFromFile > 0 ? blockFromFile : calculatedBlock);

        if (get(idxDhd).toUpperCase() == 'DH') {
          records.add(
            NormalizedPositioningRecord(
              progressOrdinal: progressOrdinal,
              departureAirport: departureAirport,
              arrivalAirport: arrivalAirport,
              departureDateTime: departureDateTime,
              arrivalDateTime: resolvedArrival,
              timeTotalMinutes: blockMinutes,
              notes: '',
            ),
          );
          continue;
        }

        final typeCode = get(idxType).toUpperCase();
        final aircraftType = ImportedAircraftTypeDraft(
          code: typeCode.isEmpty ? 'UNKNOWN' : typeCode,
          family: _southwestFamily(typeCode),
          longName: typeCode.isEmpty ? 'UNKNOWN' : typeCode,
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
        final aircraft = ImportedAircraftDraft(
          registration: get(idxTail).toUpperCase(),
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

        final takeoffCount = _parseInt(get(idxTakeoff));
        final landingCount = _parseInt(get(idxLanding));
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
        final coPilot = _parseSouthwestCoPilot(get(idxCopilot));
        final crewAssignments = <ImportedCrewAssignmentDraft>[
          ImportedCrewAssignmentDraft.self(
            position: selfPosition,
            createSelfIfMissing: false,
          ),
        ];
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
            timeIfrMinutes: options.recalculateIfrTime ? blockMinutes : 0,
            timeInstrumentMinutes: options.recalculateInstrumentTime
                ? blockMinutes
                : 0,
            timeSimulatedInstrumentMinutes: 0,
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
              flightNumber: get(idxFlight),
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

DateTime? _parseSouthwestDateTime(String date, String time) {
  try {
    final d = DateFormat('yyyy-MM-dd').parseStrict(date.trim());
    final parts = time.trim().split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]) ?? -1;
    final minute = int.tryParse(parts[1]) ?? -1;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return _southwestCsvCentralTimeToDbUtc(
      year: d.year,
      month: d.month,
      day: d.day,
      hour: hour,
      minute: minute,
    );
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

DateTime _southwestCsvCentralTimeToDbUtc({
  required int year,
  required int month,
  required int day,
  required int hour,
  required int minute,
}) {
  final local = DateTime(year, month, day, hour, minute);
  final dstStart = _secondSunday(year, 3, 2);
  final dstEnd = _firstSunday(year, 11, 2);
  final isDst = !local.isBefore(dstStart) && local.isBefore(dstEnd);
  final offsetHours = isDst ? 5 : 6;
  return DateTime.utc(year, month, day, hour, minute).add(
    Duration(hours: offsetHours),
  );
}

DateTime _firstSunday(int year, int month, int hour) {
  final firstDay = DateTime(year, month, 1, hour);
  final delta = (DateTime.sunday - firstDay.weekday + 7) % 7;
  return firstDay.add(Duration(days: delta));
}

DateTime _secondSunday(int year, int month, int hour) {
  return _firstSunday(year, month, hour).add(const Duration(days: 7));
}

class _SouthwestCopilot {
  const _SouthwestCopilot({required this.name, required this.staffNumber});

  final String name;
  final String? staffNumber;
}
