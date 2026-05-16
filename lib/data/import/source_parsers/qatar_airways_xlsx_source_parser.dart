import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/qatar_airways_import_options.dart';
import 'package:simplelog/data/import/qatar_airways_workbook_inspector.dart';

/// Parses Qatar Airways XLSX exports into normalized import records.
class QatarAirwaysXlsxSourceParser {
  /// Creates a parser.
  const QatarAirwaysXlsxSourceParser();

  /// Parses a recognized Qatar Airways workbook into a normalized batch.
  NormalizedImportBatch parse(
    QatarAirwaysWorkbookInspection workbook, {
    required QatarAirwaysImportOptions options,
    required Map<String, Airport> existingAirportsByIata,
    required Map<String, String> existingSimulatorTypeCodesByRegistration,
  }) {
    final records = <NormalizedImportRecord>[];
    var skipped = 0;
    var errors = 0;
    var progressOrdinal = 0;

    for (final row in workbook.rows) {
      progressOrdinal += 1;
      try {
        final hasFlight = row.read(_flightDateColumn).trim().isNotEmpty;
        final hasSimulator = row.read(_simDateColumn).trim().isNotEmpty;
        if (!hasFlight && !hasSimulator) {
          skipped += 1;
          continue;
        }

        if (hasFlight) {
          final flightRecord = _buildFlightRecord(
            row,
            progressOrdinal: progressOrdinal,
            options: options,
            existingAirportsByIata: existingAirportsByIata,
          );
          if (flightRecord == null) {
            skipped += 1;
          } else {
            records.add(flightRecord);
          }
        }

        if (hasSimulator) {
          final simulatorRecord = _buildSimulatorRecord(
            row,
            progressOrdinal: progressOrdinal,
            options: options,
            existingSimulatorTypeCodesByRegistration:
                existingSimulatorTypeCodesByRegistration,
          );
          if (simulatorRecord == null) {
            skipped += 1;
          } else {
            records.add(simulatorRecord);
          }
        }
      } on FormatException {
        errors += 1;
      }
    }

    return NormalizedImportBatch(
      totalRows: workbook.rows.length,
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

  NormalizedFlightRecord? _buildFlightRecord(
    QatarAirwaysWorkbookRow row, {
    required int progressOrdinal,
    required QatarAirwaysImportOptions options,
    required Map<String, Airport> existingAirportsByIata,
  }) {
    final dateText = row.read(_flightDateColumn);
    final departureIata = _normalizedCode(row.read(_departureAirportColumn));
    final arrivalIata = _normalizedCode(row.read(_arrivalAirportColumn));
    final departureTimeText = row.read(_departureTimeColumn);
    final arrivalTimeText = row.read(_arrivalTimeColumn);
    final aircraftTypeCode = _normalizedCode(row.read(_aircraftTypeColumn));
    final aircraftRegistration = _normalizedCode(row.read(_aircraftRegColumn));
    if (dateText.isEmpty ||
        departureIata.isEmpty ||
        arrivalIata.isEmpty ||
        departureTimeText.isEmpty ||
        arrivalTimeText.isEmpty ||
        aircraftTypeCode.isEmpty ||
        aircraftRegistration.isEmpty) {
      return null;
    }

    final departureAirport = _resolveAirport(
      departureIata,
      existingAirportsByIata,
    );
    final arrivalAirport = _resolveAirport(arrivalIata, existingAirportsByIata);

    final flightDate = _parseDate(dateText);
    final departureDateTime = _parseUtcDateTime(
      flightDate,
      departureTimeText,
    );
    final arrivalDateTime = _parseArrivalUtcDateTime(
      flightDate,
      arrivalTimeText,
      departureDateTime,
    );
    final totalDurationMinutes = arrivalDateTime
        .difference(departureDateTime)
        .inMinutes;
    final blockMinutes = _parseDurationMinutes(
      row.read(_totalFlightTimeColumn),
    );
    final multiPilotMinutes = _parseDurationMinutes(
      row.read(_multiPilotTimeColumn),
    );

    final crewAssignments = _buildCrewAssignments(
      picNamesRaw: row.read(_picNamesColumn),
      options: options,
    );
    return NormalizedFlightRecord(
      progressOrdinal: progressOrdinal,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      aircraftType: _buildAircraftTypeDraft(
        aircraftTypeCode,
        multiPilotMinutes > 0,
      ),
      aircraft: ImportedAircraftDraft(
        registration: aircraftRegistration,
        mtow: null,
        isSimulator: false,
      ),
      departureDateTime: departureDateTime,
      arrivalDateTime: arrivalDateTime,
      timePicMinutes: _parseDurationMinutes(row.read(_picTimeColumn)),
      timePicusMinutes: 0,
      timeSicMinutes: _parseDurationMinutes(row.read(_sicTimeColumn)),
      timeDualMinutes: 0,
      timeInstructorMinutes: _parseDurationMinutes(
        row.read(_instructorTimeColumn),
      ),
      timeIfrMinutes: _parseDurationMinutes(row.read(_ifrTimeColumn)),
      timeNightMinutes: _parseDurationMinutes(row.read(_nightTimeColumn)),
      timeCrossCountryMinutes: 0,
      timeCustom1Minutes: 0,
      timeCustom2Minutes: 0,
      timeCustom3Minutes: 0,
      timeCustom4Minutes: 0,
      timeFlightMinutes: 0,
      timeBlockMinutes: blockMinutes,
      timeTotalBlockMinutes: totalDurationMinutes,
      distanceNm: 0,
      ifrApproaches: 0,
      takeoffsDay: _parseInt(row.read(_takeOffDayColumn)),
      takeoffsNight: _parseInt(row.read(_takeOffNightColumn)),
      landingsDay: _parseInt(row.read(_landingsDayColumn)),
      landingsNight: _parseInt(row.read(_landingsNightColumn)),
      pilotFunction: 'PF',
      approachType: '',
      remarks: '',
      notes: row.read(_notesColumn),
      crewAssignments: crewAssignments,
      matchExistingByFlightDateKey: true,
    );
  }

  NormalizedSimulatorRecord? _buildSimulatorRecord(
    QatarAirwaysWorkbookRow row, {
    required int progressOrdinal,
    required QatarAirwaysImportOptions options,
    required Map<String, String> existingSimulatorTypeCodesByRegistration,
  }) {
    final dateText = row.read(_simDateColumn);
    final simulatorRegistration = _normalizedCode(row.read(_simTypeColumn));
    final simulatorTypeCode =
        _normalizedCode(
          row.read(_aircraftTypeColumn),
        ).isEmpty
        ? existingSimulatorTypeCodesByRegistration[_normalizedKey(
                simulatorRegistration,
              )] ??
              ''
        : _normalizedCode(row.read(_aircraftTypeColumn));
    if (dateText.isEmpty || simulatorRegistration.isEmpty) {
      return null;
    }
    if (simulatorTypeCode.isEmpty) {
      return null;
    }
    final timeTotal = _parseDurationMinutes(row.read(_simTotalTimeColumn));
    final startDateTime = _parseUtcDateTime(_parseDate(dateText), '00:00');
    return NormalizedSimulatorRecord(
      progressOrdinal: progressOrdinal,
      aircraftType: _buildAircraftTypeDraft(simulatorTypeCode, true),
      aircraft: ImportedAircraftDraft(
        registration: simulatorRegistration,
        mtow: null,
        isSimulator: true,
      ),
      startDateTime: startDateTime,
      endDateTime: startDateTime.add(Duration(minutes: timeTotal)),
      timeTotal: timeTotal,
      remarks: '',
      notes: row.read(_notesColumn),
      crewAssignments: _buildCrewAssignments(
        picNamesRaw: row.read(_picNamesColumn),
        options: options,
      ),
    );
  }

  ImportedAirportDraft _resolveAirport(
    String iata,
    Map<String, Airport> existingAirportsByIata,
  ) {
    final airport = existingAirportsByIata[_normalizedKey(iata)];
    if (airport == null) {
      throw FormatException('Unknown airport $iata.');
    }
    return ImportedAirportDraft(
      icao: airport.icao,
      iata: airport.iata ?? iata,
      name: airport.name ?? '',
      city: airport.city ?? '',
      country: airport.country ?? '',
      latitude: airport.latitude,
      longitude: airport.longitude,
      latitudeRaw: airport.latitude == 0 ? '' : '${airport.latitude}',
      longitudeRaw: airport.longitude == 0 ? '' : '${airport.longitude}',
    );
  }

  ImportedAircraftTypeDraft _buildAircraftTypeDraft(
    String typeCode,
    bool multiPilot,
  ) {
    final code = typeCode.isEmpty ? 'UNKNOWN' : typeCode;
    return ImportedAircraftTypeDraft(
      code: code,
      family: code,
      longName: code,
      manufacturer: '',
      category: AircraftCategory.landplane,
      engineType: EngineType.jet,
      mtow: 0,
      engineCount: 2,
      multiPilot: multiPilot,
      complex: true,
      efis: true,
      highPerformance: true,
    );
  }

  List<ImportedCrewAssignmentDraft> _buildCrewAssignments({
    required String picNamesRaw,
    required QatarAirwaysImportOptions options,
  }) {
    final assignments = <ImportedCrewAssignmentDraft>[];
    final picNames = _splitNames(picNamesRaw);
    if (options.defaultPosition == CrewPosition.sic) {
      assignments.add(
        const ImportedCrewAssignmentDraft.self(
          position: CrewPosition.sic,
          createSelfIfMissing: false,
        ),
      );
      for (final name in picNames) {
        assignments.add(
          ImportedCrewAssignmentDraft.crew(
            position: CrewPosition.pic,
            crew: ImportedCrewDraft(name: name),
          ),
        );
      }
      return assignments;
    }

    final normalizedMyName = _normalizedName(options.myName);
    final otherPicNames = <String>[];
    var hasSelfNamedPic = false;
    for (final name in picNames) {
      if (_normalizedName(name) == normalizedMyName) {
        hasSelfNamedPic = true;
        continue;
      }
      otherPicNames.add(name);
    }
    for (final name in otherPicNames) {
      assignments.add(
        ImportedCrewAssignmentDraft.crew(
          position: CrewPosition.pic,
          crew: ImportedCrewDraft(name: name),
        ),
      );
    }
    assignments.add(
      ImportedCrewAssignmentDraft.self(
        position: hasSelfNamedPic && otherPicNames.isEmpty
            ? CrewPosition.pic
            : CrewPosition.reliefCaptain,
        createSelfIfMissing: false,
      ),
    );
    return assignments;
  }

  List<String> _splitNames(String raw) {
    return raw
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  DateTime _parseDate(String value) {
    final parts = value.trim().split('/');
    if (parts.length != 3) {
      throw FormatException('Invalid date: $value');
    }
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = 2000 + int.parse(parts[2]);
    return DateTime.utc(year, month, day);
  }

  DateTime _parseUtcDateTime(DateTime date, String hhMm) {
    final cleaned = hhMm.trim();
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(cleaned);
    if (match == null) {
      throw FormatException('Invalid time: $hhMm');
    }
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    return DateTime.utc(date.year, date.month, date.day, hour, minute);
  }

  DateTime _parseArrivalUtcDateTime(
    DateTime date,
    String value,
    DateTime departureDateTime,
  ) {
    var result = _parseUtcDateTime(date, value);
    if (value.contains('(+1)')) {
      result = result.add(const Duration(days: 1));
    } else if (result.isBefore(departureDateTime)) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  int _parseDurationMinutes(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 0;
    final match = RegExp(r'^(\d{1,3}):(\d{2})$').firstMatch(trimmed);
    if (match == null) {
      throw FormatException('Invalid duration: $value');
    }
    final hours = int.parse(match.group(1)!);
    final minutes = int.parse(match.group(2)!);
    return (hours * 60) + minutes;
  }

  int _parseInt(String value) => int.tryParse(value.trim()) ?? 0;

  String _normalizedCode(String value) => value.trim().toUpperCase();

  String _normalizedKey(String value) => value.trim().toLowerCase();

  String _normalizedName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}

const _flightDateColumn = 'DATE (dd/mm/yy)';
const _departureAirportColumn = 'DEPARTURE PLACE';
const _departureTimeColumn = 'DEPARTURE TIME';
const _arrivalAirportColumn = 'ARRIVAL PLACE';
const _arrivalTimeColumn = 'ARRIVAL TIME';
const _aircraftTypeColumn = 'AIRCRAFT TYPE';
const _aircraftRegColumn = 'AIRCRAFT REG';
const _multiPilotTimeColumn = 'MULTI PILOT TIME';
const _totalFlightTimeColumn = 'TOTAL TIME OF FLIGHT';
const _picNamesColumn = 'NAME(S) PIC';
const _takeOffDayColumn = 'TAKE OFF DAY';
const _takeOffNightColumn = 'TAKE OFF NIGHT';
const _landingsDayColumn = 'LANDINGS DAY';
const _landingsNightColumn = 'LANDINGS NIGHT';
const _nightTimeColumn = 'OPERATIONAL CONDITION TIME NIGHT';
const _ifrTimeColumn = 'OPERATIONAL CONDITION TIME IFR';
const _picTimeColumn = 'PILOT FUNCTION TIME PIC';
const _sicTimeColumn = 'PILOT FUNCTION TIME CO-PILOT';
const _instructorTimeColumn = 'PILOT FUNCTION TIME INSTRUCTOR';
const _simDateColumn = 'FSTD SESSION DATE (dd/mm/yy)';
const _simTypeColumn = 'FSTD SESSION TYPE';
const _simTotalTimeColumn = 'FSTD SESSION TOTAL TIME';
const _notesColumn = 'REMARKS AND ENDORSEMENTS';
