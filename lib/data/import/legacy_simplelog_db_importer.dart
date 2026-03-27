import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:drift/drift.dart' as d;
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/core/flight/pilot_function_logic.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Summary of imported rows from a legacy SimpleLog database.
class LegacySimpleLogDbImportResult {
  /// Creates a summary result.
  const LegacySimpleLogDbImportResult({
    required this.aircraftTypes,
    required this.aircrafts,
    required this.airports,
    required this.crew,
    required this.flights,
    required this.simulators,
    required this.flightCrewAssignments,
    required this.simulatorCrewAssignments,
  });

  /// Imported aircraft type count.
  final int aircraftTypes;

  /// Imported aircraft count.
  final int aircrafts;

  /// Imported airport count.
  final int airports;

  /// Imported crew count.
  final int crew;

  /// Imported flight count.
  final int flights;

  /// Imported simulator count.
  final int simulators;

  /// Imported flight-crew assignment count.
  final int flightCrewAssignments;

  /// Imported sim-crew assignment count.
  final int simulatorCrewAssignments;
}

/// Imports legacy SimpleLog sqlite/mysql-export databases into current schema.
class LegacySimpleLogDbImporter {
  /// Creates an importer bound to the current app database.
  const LegacySimpleLogDbImporter(this._db);

  final AppDatabase _db;

  /// Imports from raw sqlite bytes.
  Future<LegacySimpleLogDbImportResult> importFromBytes(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final tempPath =
        '${dir.path}${Platform.pathSeparator}'
        'legacy_simplelog_${DateTime.now().microsecondsSinceEpoch}.sqlite';
    final tempFile = File(tempPath);
    if (!tempFile.parent.existsSync()) {
      tempFile.parent.createSync(recursive: true);
    }
    await tempFile.writeAsBytes(bytes, flush: true);
    try {
      return await importFromPath(tempPath);
    } finally {
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
    }
  }

  /// Imports from a sqlite file path.
  Future<LegacySimpleLogDbImportResult> importFromPath(String path) async {
    final source = sqlite.sqlite3.open(path);
    try {
      return _importFromSource(source);
    } finally {
      source.close();
    }
  }

  Future<LegacySimpleLogDbImportResult> _importFromSource(
    sqlite.Database source,
  ) async {
    final modelRows = _trySelect(source, 'SELECT * FROM model');
    final aircraftRows = _trySelect(source, 'SELECT * FROM aircraft');
    final airportRows = _trySelect(source, 'SELECT * FROM airport');
    final crewRows = _trySelect(source, 'SELECT * FROM crew');
    final flightRows = _trySelect(source, 'SELECT * FROM flight');

    final simulatorAircraftIds = aircraftRows
        .where((row) => _asBool(row['simulator']))
        .map((row) => _asInt(row['aircraft_id']))
        .whereType<int>()
        .toSet();

    final airportCoords = <int, (double lat, double lon)>{};
    for (final row in airportRows) {
      final id = _asInt(row['airport_id']);
      final lat = _asDouble(row['latitude']);
      final lon = _asDouble(row['longitude']);
      if (id == null || lat == null || lon == null) continue;
      airportCoords[id] = (lat, lon);
    }

    var insertedAircraftTypes = 0;
    var insertedAircrafts = 0;
    var insertedAirports = 0;
    var insertedCrew = 0;
    var insertedFlights = 0;
    var insertedSims = 0;
    var insertedFlightAssignments = 0;
    var insertedSimAssignments = 0;

    await _db.runWithLockWriteBypass(() async {
      await _db.transaction(() async {
        await _clearImportTargets();

        for (final row in modelRows) {
          final id = _asInt(row['model_id']);
          final modelName = _asString(row['model_name']);
          if (id == null || modelName == null || modelName.trim().isEmpty) {
            continue;
          }
          await _db
              .into(_db.aircraftTypes)
              .insert(
                AircraftTypesCompanion.insert(
                  id: d.Value(id),
                  code: modelName.trim(),
                  family: (_asString(row['model_group']) ?? '').trim(),
                  longName: modelName.trim(),
                  manufacturer: const d.Value(null),
                  category: _asBool(row['seaplane'])
                      ? AircraftCategory.seaplane
                      : AircraftCategory.landplane,
                  engineType: _parseEngineType(_asString(row['engine_type'])),
                  mtow: _asInt(row['mtow']) ?? 0,
                  engineCount: _asBool(row['multi_engine']) ? 2 : 1,
                  multiPilot: _asBool(row['multi_pilot']),
                  complex: false,
                  efis: _asBool(row['efis']),
                  highPerformance: false,
                  isLocked: false,
                ),
                mode: d.InsertMode.insertOrReplace,
              );
          insertedAircraftTypes += 1;
        }

        for (final row in aircraftRows) {
          final id = _asInt(row['aircraft_id']);
          final modelId = _asInt(row['model_id']);
          final registration = _asString(row['registration']);
          if (id == null ||
              modelId == null ||
              registration == null ||
              registration.trim().isEmpty) {
            continue;
          }
          await _db
              .into(_db.aircrafts)
              .insert(
                AircraftsCompanion.insert(
                  id: d.Value(id),
                  aircraftTypeId: modelId,
                  registration: registration.trim(),
                  mtow: d.Value(_asInt(row['aircraft_mtow'])),
                  isSimulator: _asBool(row['simulator']),
                  isFavorite: false,
                  isLocked: false,
                  notes: const d.Value(null),
                ),
                mode: d.InsertMode.insertOrReplace,
              );
          insertedAircrafts += 1;
        }

        for (final row in airportRows) {
          final id = _asInt(row['airport_id']);
          final icao = _asString(row['icao']);
          final lat = _asDouble(row['latitude']);
          final lon = _asDouble(row['longitude']);
          if (id == null ||
              icao == null ||
              icao.trim().isEmpty ||
              lat == null ||
              lon == null) {
            continue;
          }
          await _db
              .into(_db.airports)
              .insert(
                AirportsCompanion.insert(
                  id: d.Value(id),
                  icao: icao.trim().toUpperCase(),
                  iata: d.Value(_cleanNullableUpper(_asString(row['iata']))),
                  name: d.Value(_cleanNullable(_asString(row['airport_name']))),
                  city: d.Value(_cleanNullable(_asString(row['airport_city']))),
                  country: d.Value(
                    _cleanNullable(_asString(row['airport_country'])),
                  ),
                  latitude: lat,
                  longitude: lon,
                  isFavorite: false,
                  isLocked: false,
                ),
                mode: d.InsertMode.insertOrReplace,
              );
          insertedAirports += 1;
        }

        for (final row in crewRows) {
          final id = _asInt(row['crew_id']);
          final name = _asString(row['crew_name']);
          if (id == null || name == null || name.trim().isEmpty) continue;
          await _db
              .into(_db.crew)
              .insert(
                CrewCompanion.insert(
                  id: d.Value(id),
                  name: name.trim(),
                  email: d.Value(_cleanNullable(_asString(row['email']))),
                  notes: d.Value(_cleanNullable(_asString(row['comments']))),
                  phone: d.Value(_cleanNullable(_asString(row['phone']))),
                  picture: const d.Value(null),
                  isSelf: false,
                  isFavorite: false,
                  isLocked: false,
                ),
                mode: d.InsertMode.insertOrReplace,
              );
          insertedCrew += 1;
        }

        for (final row in flightRows) {
          final flightId = _asInt(row['flight_id']);
          final depEpochRaw = _asInt(row['departure_date']);
          final depAirportId = _asInt(row['departure_airport_id']);
          final arrAirportId = _asInt(row['arrival_airport_id']);
          final aircraftId = _asInt(row['aircraft_id']);
          if (flightId == null ||
              depEpochRaw == null ||
              depAirportId == null ||
              arrAirportId == null ||
              aircraftId == null) {
            continue;
          }

          final departureDateTime = _epochToUtc(depEpochRaw);
          final arrivalDateTime = _epochToUtcOrNull(
            _asInt(row['arrival_date']),
          );
          final departureTimelineId = await _db
              .into(_db.timeLines)
              .insert(
                TimeLinesCompanion.insert(eventDateTime: departureDateTime),
              );

          final isSimulator = simulatorAircraftIds.contains(aircraftId);
          if (isSimulator) {
            await _db
                .into(_db.simulatorTrainings)
                .insert(
                  SimulatorTrainingsCompanion.insert(
                    id: d.Value(flightId),
                    aircraftId: aircraftId,
                    startTimeLineId: departureTimelineId,
                    endDateTime: d.Value(arrivalDateTime),
                    timeTotal:
                        _asInt(row['fstd_time']) ??
                        _asInt(row['total_time']) ??
                        0,
                    remarks: (_asString(row['remarks']) ?? '').trim(),
                    notes: (_asString(row['private_notes']) ?? '').trim(),
                    isLocked: false,
                    signatureImage: const d.Value(null),
                    endorsementData: const d.Value(null),
                    endorsementHash: const d.Value(null),
                  ),
                  mode: d.InsertMode.insertOrReplace,
                );
            insertedSims += 1;

            final simPicId = _asInt(row['crew_pic_id']);
            if (simPicId != null && simPicId > 0) {
              await _db
                  .into(_db.simulatorCrewAssignments)
                  .insert(
                    SimulatorCrewAssignmentsCompanion.insert(
                      simulatorId: flightId,
                      crewId: simPicId,
                      position: CrewPosition.pic,
                    ),
                  );
              insertedSimAssignments += 1;
            }
            final simSicId = _asInt(row['crew_sic_id']);
            if (simSicId != null && simSicId > 0 && simSicId != simPicId) {
              await _db
                  .into(_db.simulatorCrewAssignments)
                  .insert(
                    SimulatorCrewAssignmentsCompanion.insert(
                      simulatorId: flightId,
                      crewId: simSicId,
                      position: CrewPosition.sic,
                    ),
                  );
              insertedSimAssignments += 1;
            }
            continue;
          }

          final depCoord = airportCoords[depAirportId];
          final arrCoord = airportCoords[arrAirportId];
          final distanceNm = (depCoord == null || arrCoord == null)
              ? 0
              : _calculateDistanceNm(
                  depCoord.$1,
                  depCoord.$2,
                  arrCoord.$1,
                  arrCoord.$2,
                ).round();
          final totalBlockMinutes = _calculateBlockMinutes(
            departureDateTime,
            arrivalDateTime,
          );

          await _db
              .into(_db.flights)
              .insert(
                FlightsCompanion.insert(
                  id: d.Value(flightId),
                  aircraftId: aircraftId,
                  departureAirportId: depAirportId,
                  arrivalAirportId: arrAirportId,
                  departureDateTimeId: departureTimelineId,
                  takeOffDateTime: const d.Value(null),
                  landingDateTime: const d.Value(null),
                  arrivalDateTime: d.Value(arrivalDateTime),
                  timePICMinutes: _asInt(row['pic_time']) ?? 0,
                  timePICUSMinutes: _asInt(row['picus_time']) ?? 0,
                  timeSICMinutes: _asInt(row['sic_time']) ?? 0,
                  timeDualMinutes: _asInt(row['dual_time']) ?? 0,
                  timeInstructorMinutes: _asInt(row['instructor_time']) ?? 0,
                  timeIFRMinutes: _asInt(row['ifr_time']) ?? 0,
                  timeInstrumentMinutes: _asInt(row['ifr_time']) ?? 0,
                  timeSimulatedInstrumentMinutes:
                      _asInt(row['sim_inst_time']) ?? 0,
                  timeNightMinutes: _asInt(row['night_time']) ?? 0,
                  timeCrossCountryMinutes: _asInt(row['xc_time']) ?? 0,
                  timeCustom1Minutes: _asInt(row['custom_time1']) ?? 0,
                  timeCustom2Minutes: _asInt(row['custom_time2']) ?? 0,
                  timeCustom3Minutes: _asInt(row['custom_time3']) ?? 0,
                  timeCustom4Minutes: _asInt(row['custom_time4']) ?? 0,
                  timeFlightMinutes: 0,
                  timeBlockMinutes: _asInt(row['total_time']) ?? 0,
                  distanceNM: distanceNm,
                  ifrApproaches: _asInt(row['ifr_approaches']) ?? 0,
                  takeOffsDays: _asInt(row['take_off_day']) ?? 0,
                  takeOffsNight: _asInt(row['take_off_night']) ?? 0,
                  landingsDay: _asInt(row['landing_day']) ?? 0,
                  landingsNight: _asInt(row['landing_night']) ?? 0,
                  pilotFunction: d.Value(
                    PilotFunctionLogic.parse(
                      (_asString(row['pf_pnf']) ?? 'PF').trim().toUpperCase(),
                    ),
                  ),
                  approachType: (_asString(row['approach_type']) ?? '').trim(),
                  remarks: (_asString(row['remarks']) ?? '').trim(),
                  notes: (_asString(row['private_notes']) ?? '').trim(),
                  timeTotalBlockMinutes: d.Value(totalBlockMinutes),
                  isLocked: false,
                  signatureImage: const d.Value(null),
                  endorsementData: const d.Value(null),
                  endorsementHash: const d.Value(null),
                ),
                mode: d.InsertMode.insertOrReplace,
              );
          insertedFlights += 1;

          final picId = _asInt(row['crew_pic_id']);
          if (picId != null && picId > 0) {
            await _db
                .into(_db.flightCrewAssignments)
                .insert(
                  FlightCrewAssignmentsCompanion.insert(
                    flightId: flightId,
                    crewId: picId,
                    position: CrewPosition.pic,
                  ),
                );
            insertedFlightAssignments += 1;
          }
          final sicId = _asInt(row['crew_sic_id']);
          if (sicId != null && sicId > 0 && sicId != picId) {
            await _db
                .into(_db.flightCrewAssignments)
                .insert(
                  FlightCrewAssignmentsCompanion.insert(
                    flightId: flightId,
                    crewId: sicId,
                    position: CrewPosition.sic,
                  ),
                );
            insertedFlightAssignments += 1;
          }
        }
      });
    });

    return LegacySimpleLogDbImportResult(
      aircraftTypes: insertedAircraftTypes,
      aircrafts: insertedAircrafts,
      airports: insertedAirports,
      crew: insertedCrew,
      flights: insertedFlights,
      simulators: insertedSims,
      flightCrewAssignments: insertedFlightAssignments,
      simulatorCrewAssignments: insertedSimAssignments,
    );
  }

  Future<void> _clearImportTargets() async {
    await _db.delete(_db.flightCrewAssignments).go();
    await _db.delete(_db.simulatorCrewAssignments).go();
    await _db.delete(_db.flights).go();
    await _db.delete(_db.simulatorTrainings).go();
    await _db.delete(_db.positionings).go();
    await _db.delete(_db.dutyPeriods).go();
    await _db.delete(_db.timeLines).go();
    await _db.delete(_db.previousExperiences).go();
    await _db.delete(_db.aircrafts).go();
    await _db.delete(_db.aircraftTypes).go();
    await _db.delete(_db.airports).go();
    await _db.delete(_db.crew).go();
  }

  List<sqlite.Row> _trySelect(sqlite.Database db, String sql) {
    try {
      return db.select(sql);
    } on Object {
      return const <sqlite.Row>[];
    }
  }

  String? _cleanNullable(String? value) {
    final next = value?.trim();
    if (next == null || next.isEmpty) return null;
    return next;
  }

  String? _cleanNullableUpper(String? value) {
    final next = value?.trim();
    if (next == null || next.isEmpty) return null;
    return next.toUpperCase();
  }

  bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == '1' || normalized == 'true' || normalized == 'yes';
    }
    return false;
  }

  int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  String? _asString(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  DateTime _epochToUtc(int epoch) {
    final millis = epoch.abs() > 100000000000 ? epoch : epoch * 1000;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  DateTime? _epochToUtcOrNull(int? epoch) {
    if (epoch == null || epoch == 0) return null;
    return _epochToUtc(epoch);
  }

  int _calculateBlockMinutes(DateTime departureUtc, DateTime? arrivalUtc) {
    if (arrivalUtc == null) return 0;
    final diff = arrivalUtc.difference(departureUtc).inMinutes;
    return diff < 0 ? 0 : diff;
  }

  EngineType _parseEngineType(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.contains('jet') || normalized.contains('turbofan')) {
      return EngineType.jet;
    }
    if (normalized.contains('turboprop')) {
      return EngineType.turboprop;
    }
    if (normalized.contains('piston')) {
      return EngineType.piston;
    }
    if (normalized.contains('electric')) {
      return EngineType.electric;
    }
    return EngineType.unknown;
  }

  double _calculateDistanceNm(
    double latDep,
    double lonDep,
    double latArr,
    double lonArr,
  ) {
    final dLat = _degToRad(latArr - latDep);
    final dLon = _degToRad(lonArr - lonDep);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(latDep)) *
            math.cos(_degToRad(latArr)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return 3443.89849 * c;
  }

  double _degToRad(double deg) => deg * math.pi / 180.0;
}
