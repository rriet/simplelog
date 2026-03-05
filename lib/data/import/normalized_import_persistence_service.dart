import 'dart:math';

import 'package:drift/drift.dart';
import 'package:simplelog/core/flight/pilot_function_logic.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/import/normalized_import_models.dart';
import 'package:simplelog/data/import/simplelog_import_result.dart';

/// Persists normalized import records into the application database.
class NormalizedImportPersistenceService {
  /// Creates a persistence service bound to a database instance.
  const NormalizedImportPersistenceService(this.db);

  /// Target application database.
  final AppDatabase db;

  /// Persists a fully normalized import batch.
  Future<SimpleLogImportResult> importBatch(
    NormalizedImportBatch batch, {
    ImportProgressCallback? onProgress,
  }) async {
    if (batch.totalRows == 0) {
      return SimpleLogImportResult(
        totalRows: 0,
        flights: 0,
        positionings: 0,
        simulators: 0,
        airports: 0,
        aircraftTypes: 0,
        aircrafts: 0,
        crew: 0,
        skipped: batch.skippedRows,
        errors: batch.errorRows,
      );
    }

    final airportCache = <String, Airport>{};
    final aircraftTypeCache = <String, AircraftType>{};
    final aircraftCache = <String, Aircraft>{};
    final crewCache = <String, CrewData>{};

    final existingAirports = await db.select(db.airports).get();
    for (final airport in existingAirports) {
      airportCache[_airportKey(airport.icao)] = airport;
    }
    final existingTypes = await db.select(db.aircraftTypes).get();
    for (final type in existingTypes) {
      aircraftTypeCache[_normalizeKey(type.code)] = type;
    }
    final existingAircraft = await db.select(db.aircrafts).get();
    for (final aircraft in existingAircraft) {
      aircraftCache[_normalizeKey(aircraft.registration)] = aircraft;
    }
    final existingCrew = await db.select(db.crew).get();
    for (final member in existingCrew) {
      crewCache[_crewKey(member.name)] = member;
    }

    final existingFlightKeys = await _loadExistingFlightDateKeys();
    final existingPositioningKeys = await _loadExistingPositioningDateKeys();
    final counters = _ImportCounters(
      skipped: batch.skippedRows,
      errors: batch.errorRows,
    );

    await db.transaction(() async {
      for (final record in batch.records) {
        try {
          if (record is NormalizedFlightRecord) {
            await _persistFlight(
              record,
              entityOptions: batch.entityOptions,
              counters: counters,
              airportCache: airportCache,
              aircraftTypeCache: aircraftTypeCache,
              aircraftCache: aircraftCache,
              crewCache: crewCache,
              existingFlightKeys: existingFlightKeys,
            );
          } else if (record is NormalizedPositioningRecord) {
            await _persistPositioning(
              record,
              entityOptions: batch.entityOptions,
              counters: counters,
              airportCache: airportCache,
              existingPositioningKeys: existingPositioningKeys,
            );
          } else if (record is NormalizedSimulatorRecord) {
            await _persistSimulator(
              record,
              entityOptions: batch.entityOptions,
              counters: counters,
              aircraftTypeCache: aircraftTypeCache,
              aircraftCache: aircraftCache,
              crewCache: crewCache,
            );
          }
        } on Object catch (_) {
          counters.errors += 1;
        }

        if (record.progressOrdinal % 250 == 0) {
          onProgress?.call(record.progressOrdinal, batch.totalRows);
        }
      }
    });

    onProgress?.call(batch.totalRows, batch.totalRows);
    return SimpleLogImportResult(
      totalRows: batch.totalRows,
      flights: counters.flights,
      positionings: counters.positionings,
      simulators: counters.simulators,
      airports: counters.airports,
      aircraftTypes: counters.aircraftTypes,
      aircrafts: counters.aircrafts,
      crew: counters.crew,
      skipped: counters.skipped,
      errors: counters.errors,
    );
  }

  Future<void> _persistFlight(
    NormalizedFlightRecord record, {
    required ImportedEntityOptions entityOptions,
    required _ImportCounters counters,
    required Map<String, Airport> airportCache,
    required Map<String, AircraftType> aircraftTypeCache,
    required Map<String, Aircraft> aircraftCache,
    required Map<String, CrewData> crewCache,
    required Map<String, _ExistingFlightData> existingFlightKeys,
  }) async {
    final depAirportId = await _getOrCreateAirport(
      draft: record.departureAirport,
      cache: airportCache,
      options: entityOptions,
    );
    if (depAirportId.created) counters.airports += 1;

    final arrAirportId = await _getOrCreateAirport(
      draft: record.arrivalAirport,
      cache: airportCache,
      options: entityOptions,
    );
    if (arrAirportId.created) counters.airports += 1;

    final aircraftTypeId = await _getOrCreateAircraftType(
      draft: record.aircraftType,
      cache: aircraftTypeCache,
      options: entityOptions,
    );
    if (aircraftTypeId?.created == true) counters.aircraftTypes += 1;
    if (aircraftTypeId == null) {
      counters.skipped += 1;
      return;
    }

    final aircraftId = await _getOrCreateAircraft(
      draft: record.aircraft,
      aircraftTypeId: aircraftTypeId.id,
      typeMtow: record.aircraftType.mtow,
      cache: aircraftCache,
      options: entityOptions,
    );
    if (aircraftId == null) {
      counters.skipped += 1;
      return;
    }
    if (aircraftId.created) counters.aircrafts += 1;

    final flightKey = _flightDateKey(
      record.departureAirport.icao,
      record.arrivalAirport.icao,
      record.departureDateTime,
      record.arrivalDateTime,
    );
    final existing = record.matchExistingByFlightDateKey
        ? existingFlightKeys[flightKey]
        : null;
    if (existing != null && !record.overrideMatchedFlight) {
      counters.skipped += 1;
      return;
    }
    if (existing != null && existing.isLocked) {
      counters.skipped += 1;
      return;
    }

    late final int flightId;
    if (existing != null) {
      await (db.update(
        db.timeLines,
      )..where((t) => t.id.equals(existing.departureTimelineId))).write(
        TimeLinesCompanion(eventDateTime: Value(record.departureDateTime)),
      );
      await (db.update(
        db.flights,
      )..where((t) => t.id.equals(existing.flightId))).write(
        FlightsCompanion(
          aircraftId: Value(aircraftId.id),
          departureAirportId: Value(depAirportId.id),
          arrivalAirportId: Value(arrAirportId.id),
          takeOffDateTime: Value(record.takeOffDateTime),
          landingDateTime: Value(record.landingDateTime),
          arrivalDateTime: Value(record.arrivalDateTime),
          timePICMinutes: Value(record.timePicMinutes),
          timePICUSMinutes: Value(record.timePicusMinutes),
          timeSICMinutes: Value(record.timeSicMinutes),
          timeDualMinutes: Value(record.timeDualMinutes),
          timeInstructorMinutes: Value(record.timeInstructorMinutes),
          timeIFRMinutes: Value(record.timeIfrMinutes),
          timeInstrumentMinutes: Value(record.timeInstrumentMinutes),
          timeSimulatedInstrumentMinutes: Value(
            record.timeSimulatedInstrumentMinutes,
          ),
          timeNightMinutes: Value(record.timeNightMinutes),
          timeCrossCountryMinutes: Value(record.timeCrossCountryMinutes),
          timeCustom1Minutes: Value(record.timeCustom1Minutes),
          timeCustom2Minutes: Value(record.timeCustom2Minutes),
          timeCustom3Minutes: Value(record.timeCustom3Minutes),
          timeCustom4Minutes: Value(record.timeCustom4Minutes),
          timeFlightMinutes: Value(record.timeFlightMinutes),
          timeBlockMinutes: Value(record.timeBlockMinutes),
          timeTotalBlockMinutes: record.timeTotalBlockMinutes == null
              ? const Value.absent()
              : Value(record.timeTotalBlockMinutes!),
          distanceNM: Value(record.distanceNm),
          ifrApproaches: Value(record.ifrApproaches),
          takeOffsDays: Value(record.takeoffsDay),
          takeOffsNight: Value(record.takeoffsNight),
          landingsDay: Value(record.landingsDay),
          landingsNight: Value(record.landingsNight),
          pilotFunction: Value(PilotFunctionLogic.parse(record.pilotFunction)),
          approachType: Value(record.approachType),
          remarks: Value(record.remarks),
          notes: Value(record.notes),
        ),
      );
      await (db.delete(
        db.flightCrewAssignments,
      )..where((t) => t.flightId.equals(existing.flightId))).go();
      flightId = existing.flightId;
    } else {
      final departureTimelineId = await db
          .into(db.timeLines)
          .insert(
            TimeLinesCompanion.insert(eventDateTime: record.departureDateTime),
          );
      flightId = await db
          .into(db.flights)
          .insert(
            FlightsCompanion.insert(
              aircraftId: aircraftId.id,
              departureAirportId: depAirportId.id,
              arrivalAirportId: arrAirportId.id,
              departureDateTimeId: departureTimelineId,
              takeOffDateTime: Value(record.takeOffDateTime),
              landingDateTime: Value(record.landingDateTime),
              arrivalDateTime: Value(record.arrivalDateTime),
              timePICMinutes: record.timePicMinutes,
              timePICUSMinutes: record.timePicusMinutes,
              timeSICMinutes: record.timeSicMinutes,
              timeDualMinutes: record.timeDualMinutes,
              timeInstructorMinutes: record.timeInstructorMinutes,
              timeIFRMinutes: record.timeIfrMinutes,
              timeInstrumentMinutes: record.timeInstrumentMinutes,
              timeSimulatedInstrumentMinutes:
                  record.timeSimulatedInstrumentMinutes,
              timeNightMinutes: record.timeNightMinutes,
              timeCrossCountryMinutes: record.timeCrossCountryMinutes,
              timeCustom1Minutes: record.timeCustom1Minutes,
              timeCustom2Minutes: record.timeCustom2Minutes,
              timeCustom3Minutes: record.timeCustom3Minutes,
              timeCustom4Minutes: record.timeCustom4Minutes,
              timeFlightMinutes: record.timeFlightMinutes,
              timeBlockMinutes: record.timeBlockMinutes,
              timeTotalBlockMinutes: record.timeTotalBlockMinutes == null
                  ? const Value.absent()
                  : Value(record.timeTotalBlockMinutes!),
              distanceNM: record.distanceNm,
              ifrApproaches: record.ifrApproaches,
              takeOffsDays: record.takeoffsDay,
              takeOffsNight: record.takeoffsNight,
              landingsDay: record.landingsDay,
              landingsNight: record.landingsNight,
              pilotFunction: Value(
                PilotFunctionLogic.parse(record.pilotFunction),
              ),
              approachType: record.approachType,
              remarks: record.remarks,
              notes: record.notes,
              isLocked: false,
              signatureImage: const Value(null),
            ),
          );
      existingFlightKeys[flightKey] = _ExistingFlightData(
        flightId: flightId,
        departureTimelineId: departureTimelineId,
        isLocked: false,
      );
    }

    await _persistFlightCrewAssignments(
      flightId,
      record.crewAssignments,
      entityOptions: entityOptions,
      counters: counters,
      crewCache: crewCache,
    );
    counters.flights += 1;
  }

  Future<void> _persistPositioning(
    NormalizedPositioningRecord record, {
    required ImportedEntityOptions entityOptions,
    required _ImportCounters counters,
    required Map<String, Airport> airportCache,
    required Set<String> existingPositioningKeys,
  }) async {
    final positioningKey = _positioningDateKey(
      record.departureAirport.icao,
      record.arrivalAirport.icao,
      record.departureDateTime,
      record.arrivalDateTime,
    );
    if (existingPositioningKeys.contains(positioningKey)) {
      counters.skipped += 1;
      return;
    }

    final depAirportId = await _getOrCreateAirport(
      draft: record.departureAirport,
      cache: airportCache,
      options: entityOptions,
    );
    if (depAirportId.created) counters.airports += 1;

    final arrAirportId = await _getOrCreateAirport(
      draft: record.arrivalAirport,
      cache: airportCache,
      options: entityOptions,
    );
    if (arrAirportId.created) counters.airports += 1;

    final timelineId = await db
        .into(db.timeLines)
        .insert(
          TimeLinesCompanion.insert(eventDateTime: record.departureDateTime),
        );
    await db
        .into(db.positionings)
        .insert(
          PositioningsCompanion.insert(
            departurePlaceId: depAirportId.id,
            arrivalPlaceId: arrAirportId.id,
            departureDateTimeId: timelineId,
            arrivalDateTime: Value(record.arrivalDateTime),
            timeTotalMinutes: max(0, record.timeTotalMinutes),
            notes: Value(record.notes),
            isLocked: false,
          ),
        );
    existingPositioningKeys.add(positioningKey);
    counters.positionings += 1;
  }

  Future<void> _persistSimulator(
    NormalizedSimulatorRecord record, {
    required ImportedEntityOptions entityOptions,
    required _ImportCounters counters,
    required Map<String, AircraftType> aircraftTypeCache,
    required Map<String, Aircraft> aircraftCache,
    required Map<String, CrewData> crewCache,
  }) async {
    final aircraftTypeId = await _getOrCreateAircraftType(
      draft: record.aircraftType,
      cache: aircraftTypeCache,
      options: entityOptions,
    );
    if (aircraftTypeId?.created == true) counters.aircraftTypes += 1;
    if (aircraftTypeId == null) {
      counters.skipped += 1;
      return;
    }

    final aircraftId = await _getOrCreateAircraft(
      draft: record.aircraft,
      aircraftTypeId: aircraftTypeId.id,
      typeMtow: record.aircraftType.mtow,
      cache: aircraftCache,
      options: entityOptions,
    );
    if (aircraftId == null) {
      counters.skipped += 1;
      return;
    }
    if (aircraftId.created) counters.aircrafts += 1;

    final startTimelineId = await db
        .into(db.timeLines)
        .insert(
          TimeLinesCompanion.insert(eventDateTime: record.startDateTime),
        );
    final simulatorId = await db
        .into(db.simulatorTrainings)
        .insert(
          SimulatorTrainingsCompanion.insert(
            aircraftId: aircraftId.id,
            startTimeLineId: startTimelineId,
            endDateTime: Value(record.endDateTime),
            timeTotal: record.timeTotal,
            remarks: record.remarks,
            notes: record.notes,
            isLocked: false,
            signatureImage: const Value(null),
          ),
        );

    await _persistSimulatorCrewAssignments(
      simulatorId,
      record.crewAssignments,
      entityOptions: entityOptions,
      counters: counters,
      crewCache: crewCache,
    );
    counters.simulators += 1;
  }

  Future<void> _persistFlightCrewAssignments(
    int flightId,
    List<ImportedCrewAssignmentDraft> assignments, {
    required ImportedEntityOptions entityOptions,
    required _ImportCounters counters,
    required Map<String, CrewData> crewCache,
  }) async {
    final insertedKeys = <String>{};
    for (final assignment in assignments) {
      final crewId = await _resolveCrewAssignmentId(
        assignment,
        entityOptions: entityOptions,
        counters: counters,
        crewCache: crewCache,
      );
      if (crewId == null) continue;
      final key = '$crewId:${assignment.position.name}';
      if (!insertedKeys.add(key)) continue;
      await db
          .into(db.flightCrewAssignments)
          .insert(
            FlightCrewAssignmentsCompanion.insert(
              flightId: flightId,
              crewId: crewId,
              position: assignment.position,
            ),
          );
    }
  }

  Future<void> _persistSimulatorCrewAssignments(
    int simulatorId,
    List<ImportedCrewAssignmentDraft> assignments, {
    required ImportedEntityOptions entityOptions,
    required _ImportCounters counters,
    required Map<String, CrewData> crewCache,
  }) async {
    final insertedKeys = <String>{};
    for (final assignment in assignments) {
      final crewId = await _resolveCrewAssignmentId(
        assignment,
        entityOptions: entityOptions,
        counters: counters,
        crewCache: crewCache,
      );
      if (crewId == null) continue;
      final key = '$crewId:${assignment.position.name}';
      if (!insertedKeys.add(key)) continue;
      await db
          .into(db.simulatorCrewAssignments)
          .insert(
            SimulatorCrewAssignmentsCompanion.insert(
              simulatorId: simulatorId,
              crewId: crewId,
              position: assignment.position,
            ),
          );
    }
  }

  Future<int?> _resolveCrewAssignmentId(
    ImportedCrewAssignmentDraft assignment, {
    required ImportedEntityOptions entityOptions,
    required _ImportCounters counters,
    required Map<String, CrewData> crewCache,
  }) async {
    if (assignment.assignSelf) {
      if (assignment.createSelfIfMissing) {
        return _getOrCreateSelfCrewId(cache: crewCache);
      }
      final existingSelf = crewCache.values.where((member) => member.isSelf);
      if (existingSelf.isNotEmpty) return existingSelf.first.id;
      final namedSelf = crewCache[_crewKey('Self')];
      return namedSelf?.id;
    }

    final crew = assignment.crew;
    if (crew == null) return null;
    final result = await _getOrCreateCrew(
      draft: crew,
      cache: crewCache,
      options: entityOptions,
    );
    if (result?.created == true) counters.crew += 1;
    return result?.id;
  }

  Future<Map<String, _ExistingFlightData>> _loadExistingFlightDateKeys() async {
    final result = <String, _ExistingFlightData>{};
    final query = db.customSelect(
      '''
SELECT f.id AS flight_id,
       f.is_locked AS is_locked,
       f.arrival_date_time AS arrival_date_time,
       f.departure_date_time_id AS departure_timeline_id,
       tl.event_date_time AS departure_date_time,
       dep.icao AS departure_airport_icao,
       arr.icao AS arrival_airport_icao
FROM flights f
INNER JOIN time_lines tl ON tl.id = f.departure_date_time_id
INNER JOIN airports dep ON dep.id = f.departure_airport_id
INNER JOIN airports arr ON arr.id = f.arrival_airport_id
''',
      readsFrom: {db.flights, db.timeLines, db.airports},
    );
    final rows = await query.get();
    for (final row in rows) {
      final flightId = row.read<int>('flight_id');
      final isLocked = row.read<bool>('is_locked');
      final departureTimelineId = row.read<int>('departure_timeline_id');
      final departureAirportIcao = row.read<String>('departure_airport_icao');
      final arrivalAirportIcao = row.read<String>('arrival_airport_icao');
      final departure = row.read<DateTime>('departure_date_time');
      final arrival = row.readNullable<DateTime>('arrival_date_time');
      result[_flightDateKey(
        departureAirportIcao,
        arrivalAirportIcao,
        departure,
        arrival,
      )] = _ExistingFlightData(
        flightId: flightId,
        departureTimelineId: departureTimelineId,
        isLocked: isLocked,
      );
    }
    return result;
  }

  Future<Set<String>> _loadExistingPositioningDateKeys() async {
    final result = <String>{};
    final query = db.customSelect(
      '''
SELECT p.arrival_date_time AS arrival_date_time,
       tl.event_date_time AS departure_date_time,
       dep.icao AS departure_airport_icao,
       arr.icao AS arrival_airport_icao
FROM positionings p
INNER JOIN time_lines tl ON tl.id = p.departure_date_time_id
INNER JOIN airports dep ON dep.id = p.departure_place_id
INNER JOIN airports arr ON arr.id = p.arrival_place_id
''',
      readsFrom: {db.positionings, db.timeLines, db.airports},
    );
    final rows = await query.get();
    for (final row in rows) {
      final departureAirportIcao = row.read<String>('departure_airport_icao');
      final arrivalAirportIcao = row.read<String>('arrival_airport_icao');
      final departure = row.read<DateTime>('departure_date_time');
      final arrival = row.readNullable<DateTime>('arrival_date_time');
      result.add(
        _positioningDateKey(
          departureAirportIcao,
          arrivalAirportIcao,
          departure,
          arrival,
        ),
      );
    }
    return result;
  }

  Future<_IdResult> _getOrCreateAirport({
    required ImportedAirportDraft draft,
    required Map<String, Airport> cache,
    required ImportedEntityOptions options,
  }) async {
    final key = _airportKey(draft.icao);
    final existing = cache[key];
    if (existing != null) {
      if (!options.overrideAirportValues) {
        return _IdResult(id: existing.id, created: false);
      }

      final hasIata = draft.iata.trim().isNotEmpty;
      final hasName = draft.name.trim().isNotEmpty;
      final hasCity = draft.city.trim().isNotEmpty;
      final hasCountry = draft.country.trim().isNotEmpty;
      final hasLat = draft.latitudeRaw.trim().isNotEmpty;
      final hasLon = draft.longitudeRaw.trim().isNotEmpty;

      final mergedIata = _mergeText(existing.iata, draft.iata, hasIata);
      final mergedName = _mergeText(existing.name, draft.name, hasName);
      final mergedCity = _mergeText(existing.city, draft.city, hasCity);
      final mergedCountry = _mergeText(
        existing.country,
        draft.country,
        hasCountry,
      );
      final mergedLat = hasLat ? draft.latitude : existing.latitude;
      final mergedLon = hasLon ? draft.longitude : existing.longitude;

      final hasAirportChanges =
          mergedIata != existing.iata ||
          mergedName != existing.name ||
          mergedCity != existing.city ||
          mergedCountry != existing.country ||
          mergedLat != existing.latitude ||
          mergedLon != existing.longitude;
      if (!hasAirportChanges) {
        return _IdResult(id: existing.id, created: false);
      }

      await (db.update(
        db.airports,
      )..where((tbl) => tbl.id.equals(existing.id))).write(
        AirportsCompanion(
          iata: Value(mergedIata),
          name: Value(mergedName),
          city: Value(mergedCity),
          country: Value(mergedCountry),
          latitude: Value(mergedLat),
          longitude: Value(mergedLon),
        ),
      );

      cache[key] = Airport(
        id: existing.id,
        icao: existing.icao,
        iata: mergedIata,
        name: mergedName,
        city: mergedCity,
        country: mergedCountry,
        latitude: mergedLat,
        longitude: mergedLon,
        isFavorite: existing.isFavorite,
        isLocked: existing.isLocked,
      );
      return _IdResult(id: existing.id, created: false);
    }

    final id = await db
        .into(db.airports)
        .insert(
          AirportsCompanion.insert(
            icao: draft.icao.toUpperCase(),
            iata: draft.iata.trim().isEmpty
                ? const Value(null)
                : Value(draft.iata),
            name: draft.name.trim().isEmpty
                ? const Value(null)
                : Value(draft.name),
            city: draft.city.trim().isEmpty
                ? const Value(null)
                : Value(draft.city),
            country: draft.country.trim().isEmpty
                ? const Value(null)
                : Value(draft.country),
            latitude: draft.latitude,
            longitude: draft.longitude,
            isFavorite: false,
            isLocked: false,
          ),
        );
    cache[key] = Airport(
      id: id,
      icao: draft.icao.toUpperCase(),
      iata: draft.iata.trim().isEmpty ? null : draft.iata.trim(),
      name: draft.name.trim().isEmpty ? null : draft.name.trim(),
      city: draft.city.trim().isEmpty ? null : draft.city.trim(),
      country: draft.country.trim().isEmpty ? null : draft.country.trim(),
      latitude: draft.latitude,
      longitude: draft.longitude,
      isFavorite: false,
      isLocked: false,
    );
    return _IdResult(id: id, created: true);
  }

  Future<_IdResult?> _getOrCreateAircraftType({
    required ImportedAircraftTypeDraft draft,
    required Map<String, AircraftType> cache,
    required ImportedEntityOptions options,
  }) async {
    final clean = draft.code.trim();
    if (clean.isEmpty) return null;
    final key = _normalizeKey(clean);
    final existing = cache[key];
    if (existing != null) {
      if (!options.overrideAircraftTypeValues) {
        return _IdResult(id: existing.id, created: false);
      }
      if (existing.isLocked) {
        return _IdResult(id: existing.id, created: false);
      }

      final mergedFamily = _mergeText(
        existing.family,
        draft.family,
        draft.family.trim().isNotEmpty,
      );
      final mergedLongName = _mergeText(
        existing.longName,
        draft.longName,
        draft.longName.trim().isNotEmpty,
      );
      final mergedManufacturer = _mergeText(
        existing.manufacturer,
        draft.manufacturer,
        draft.manufacturer.trim().isNotEmpty,
      );
      final mergedCategory = draft.category;
      final mergedEngineType = draft.engineType;
      final mergedMtow = draft.mtow > 0 ? draft.mtow : existing.mtow;
      final mergedEngineCount = draft.engineCount > 0
          ? draft.engineCount
          : existing.engineCount;
      final mergedMultiPilot = draft.multiPilot;
      final mergedComplex = draft.complex;
      final mergedEfis = draft.efis;
      final mergedHighPerformance = draft.highPerformance;

      final hasAircraftTypeChanges =
          (mergedFamily ?? clean) != existing.family ||
          (mergedLongName ?? clean) != existing.longName ||
          mergedManufacturer != existing.manufacturer ||
          mergedCategory != existing.category ||
          mergedEngineType != existing.engineType ||
          mergedMtow != existing.mtow ||
          mergedEngineCount != existing.engineCount ||
          mergedMultiPilot != existing.multiPilot ||
          mergedComplex != existing.complex ||
          mergedEfis != existing.efis ||
          mergedHighPerformance != existing.highPerformance;
      if (!hasAircraftTypeChanges) {
        return _IdResult(id: existing.id, created: false);
      }

      await (db.update(
        db.aircraftTypes,
      )..where((tbl) => tbl.id.equals(existing.id))).write(
        AircraftTypesCompanion(
          family: Value(mergedFamily ?? clean),
          longName: Value(mergedLongName ?? clean),
          manufacturer: Value(mergedManufacturer),
          category: Value(mergedCategory),
          engineType: Value(mergedEngineType),
          mtow: Value(mergedMtow),
          engineCount: Value(mergedEngineCount),
          multiPilot: Value(mergedMultiPilot),
          complex: Value(mergedComplex),
          efis: Value(mergedEfis),
          highPerformance: Value(mergedHighPerformance),
        ),
      );

      cache[key] = existing.copyWith(
        family: mergedFamily ?? clean,
        longName: mergedLongName ?? clean,
        manufacturer: Value(mergedManufacturer),
        category: mergedCategory,
        engineType: mergedEngineType,
        mtow: mergedMtow,
        engineCount: mergedEngineCount,
        multiPilot: mergedMultiPilot,
        complex: mergedComplex,
        efis: mergedEfis,
        highPerformance: mergedHighPerformance,
      );
      return _IdResult(id: existing.id, created: false);
    }

    final id = await db
        .into(db.aircraftTypes)
        .insert(
          AircraftTypesCompanion.insert(
            code: clean,
            family: draft.family.trim().isEmpty ? clean : draft.family.trim(),
            longName: draft.longName.trim().isEmpty ? clean : draft.longName,
            manufacturer: draft.manufacturer.trim().isEmpty
                ? const Value(null)
                : Value(draft.manufacturer.trim()),
            category: draft.category,
            engineType: draft.engineType,
            mtow: draft.mtow,
            engineCount: draft.engineCount == 0 ? 1 : draft.engineCount,
            multiPilot: draft.multiPilot,
            complex: draft.complex,
            efis: draft.efis,
            highPerformance: draft.highPerformance,
            isLocked: false,
          ),
        );
    cache[key] = AircraftType(
      id: id,
      code: clean,
      family: draft.family.trim().isEmpty ? clean : draft.family.trim(),
      longName: draft.longName.trim().isEmpty ? clean : draft.longName.trim(),
      manufacturer: draft.manufacturer.trim().isEmpty
          ? null
          : draft.manufacturer.trim(),
      category: draft.category,
      engineType: draft.engineType,
      mtow: draft.mtow,
      engineCount: draft.engineCount == 0 ? 1 : draft.engineCount,
      multiPilot: draft.multiPilot,
      complex: draft.complex,
      efis: draft.efis,
      highPerformance: draft.highPerformance,
      isLocked: false,
    );
    return _IdResult(id: id, created: true);
  }

  Future<_IdResult?> _getOrCreateAircraft({
    required ImportedAircraftDraft draft,
    required int aircraftTypeId,
    required int typeMtow,
    required Map<String, Aircraft> cache,
    required ImportedEntityOptions options,
  }) async {
    if (draft.registration.isEmpty) return null;
    final normalizedMtow = _normalizeAircraftMtow(
      aircraftMtow: draft.mtow,
      typeMtow: typeMtow,
    );
    final key = _normalizeKey(draft.registration);
    final existing = cache[key];
    if (existing != null) {
      if (!options.overrideAircraftValues) {
        return _IdResult(id: existing.id, created: false);
      }
      if (existing.isLocked) {
        return _IdResult(id: existing.id, created: false);
      }

      final mergedTypeId = aircraftTypeId;
      final mergedMtow = normalizedMtow ?? existing.mtow;
      final mergedSimulator = draft.isSimulator;
      final mergedNotes = _mergeText(
        existing.notes,
        draft.notes,
        draft.notes.trim().isNotEmpty,
      );
      final hasAircraftChanges =
          mergedTypeId != existing.aircraftTypeId ||
          mergedMtow != existing.mtow ||
          mergedSimulator != existing.isSimulator ||
          mergedNotes != existing.notes;
      if (!hasAircraftChanges) {
        return _IdResult(id: existing.id, created: false);
      }

      await (db.update(
        db.aircrafts,
      )..where((tbl) => tbl.id.equals(existing.id))).write(
        AircraftsCompanion(
          aircraftTypeId: Value(mergedTypeId),
          mtow: Value(mergedMtow),
          isSimulator: Value(mergedSimulator),
          notes: Value(mergedNotes),
        ),
      );

      cache[key] = existing.copyWith(
        aircraftTypeId: mergedTypeId,
        mtow: Value(mergedMtow),
        isSimulator: mergedSimulator,
        notes: Value(mergedNotes),
      );
      return _IdResult(id: existing.id, created: false);
    }

    final id = await db
        .into(db.aircrafts)
        .insert(
          AircraftsCompanion.insert(
            aircraftTypeId: aircraftTypeId,
            registration: draft.registration,
            mtow: Value(normalizedMtow),
            isSimulator: draft.isSimulator,
            isFavorite: false,
            isLocked: false,
            notes: draft.notes.trim().isEmpty
                ? const Value(null)
                : Value(draft.notes.trim()),
          ),
        );
    cache[key] = Aircraft(
      id: id,
      aircraftTypeId: aircraftTypeId,
      registration: draft.registration,
      mtow: normalizedMtow,
      isSimulator: draft.isSimulator,
      isFavorite: false,
      isLocked: false,
      notes: draft.notes.trim().isEmpty ? null : draft.notes.trim(),
    );
    return _IdResult(id: id, created: true);
  }

  Future<_IdResult?> _getOrCreateCrew({
    required ImportedCrewDraft draft,
    required Map<String, CrewData> cache,
    required ImportedEntityOptions options,
  }) async {
    final clean = draft.name.trim();
    if (clean.isEmpty) return null;
    final key = _crewKey(clean);
    final existing = cache[key];
    if (existing != null) {
      if (!options.overrideCrewValues) {
        return _IdResult(id: existing.id, created: false);
      }
      if (existing.isLocked) {
        return _IdResult(id: existing.id, created: false);
      }

      final hasEmail = draft.email.trim().isNotEmpty;
      final hasPhone = draft.phone.trim().isNotEmpty;
      final hasNotes = draft.notes.trim().isNotEmpty;
      final mergedEmail = _mergeText(existing.email, draft.email, hasEmail);
      final mergedPhone = _mergeText(existing.phone, draft.phone, hasPhone);
      final mergedNotes = _mergeText(existing.notes, draft.notes, hasNotes);

      final hasCrewChanges =
          mergedEmail != existing.email ||
          mergedPhone != existing.phone ||
          mergedNotes != existing.notes;
      if (!hasCrewChanges) {
        return _IdResult(id: existing.id, created: false);
      }

      await (db.update(
        db.crew,
      )..where((tbl) => tbl.id.equals(existing.id))).write(
        CrewCompanion(
          email: Value(mergedEmail),
          phone: Value(mergedPhone),
          notes: Value(mergedNotes),
        ),
      );

      cache[key] = existing.copyWith(
        email: Value(mergedEmail),
        phone: Value(mergedPhone),
        notes: Value(mergedNotes),
      );
      return _IdResult(id: existing.id, created: false);
    }

    final id = await db
        .into(db.crew)
        .insert(
          CrewCompanion.insert(
            name: clean,
            email: draft.email.trim().isEmpty
                ? const Value(null)
                : Value(draft.email),
            notes: draft.notes.trim().isEmpty
                ? const Value(null)
                : Value(draft.notes),
            phone: draft.phone.trim().isEmpty
                ? const Value(null)
                : Value(draft.phone),
            picture: const Value(null),
            isSelf: false,
            isFavorite: false,
            isLocked: false,
          ),
        );
    cache[key] = CrewData(
      id: id,
      name: clean,
      email: draft.email.trim().isEmpty ? null : draft.email.trim(),
      notes: draft.notes.trim().isEmpty ? null : draft.notes.trim(),
      phone: draft.phone.trim().isEmpty ? null : draft.phone.trim(),
      isSelf: false,
      isFavorite: false,
      isLocked: false,
    );
    return _IdResult(id: id, created: true);
  }

  Future<int?> _getOrCreateSelfCrewId({
    required Map<String, CrewData> cache,
  }) async {
    final existingSelf = cache.values.where((member) => member.isSelf);
    if (existingSelf.isNotEmpty) {
      return existingSelf.first.id;
    }
    final namedSelf = cache[_crewKey('Self')];
    if (namedSelf != null) {
      return namedSelf.id;
    }
    final id = await db
        .into(db.crew)
        .insert(
          CrewCompanion.insert(
            name: 'Self',
            email: const Value(null),
            notes: const Value(null),
            phone: const Value(null),
            picture: const Value(null),
            isSelf: true,
            isFavorite: false,
            isLocked: false,
          ),
        );
    cache[_crewKey('Self')] = CrewData(
      id: id,
      name: 'Self',
      isSelf: true,
      isFavorite: false,
      isLocked: false,
    );
    return id;
  }
}

class _ImportCounters {
  _ImportCounters({this.skipped = 0, this.errors = 0});

  int flights = 0;
  int positionings = 0;
  int simulators = 0;
  int airports = 0;
  int aircraftTypes = 0;
  int aircrafts = 0;
  int crew = 0;
  int skipped;
  int errors;
}

class _IdResult {
  const _IdResult({required this.id, required this.created});

  final int id;
  final bool created;
}

class _ExistingFlightData {
  const _ExistingFlightData({
    required this.flightId,
    required this.departureTimelineId,
    required this.isLocked,
  });

  final int flightId;
  final int departureTimelineId;
  final bool isLocked;
}

String _normalizeKey(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[\s\-]'), '');
}

String _airportKey(String icao) => icao.trim().toLowerCase();

String _crewKey(String name) => name.trim().toLowerCase();

String _flightDateKey(
  String departureAirportIcao,
  String arrivalAirportIcao,
  DateTime departure,
  DateTime? arrival,
) {
  return '${departureAirportIcao.trim().toUpperCase()}|'
      '${arrivalAirportIcao.trim().toUpperCase()}|'
      '${departure.millisecondsSinceEpoch}|'
      '${arrival?.millisecondsSinceEpoch ?? -1}';
}

String _positioningDateKey(
  String departureAirportIcao,
  String arrivalAirportIcao,
  DateTime departure,
  DateTime? arrival,
) {
  return '${departureAirportIcao.trim().toUpperCase()}|'
      '${arrivalAirportIcao.trim().toUpperCase()}|'
      '${departure.millisecondsSinceEpoch}|'
      '${arrival?.millisecondsSinceEpoch ?? -1}';
}

String? _mergeText(String? existing, String incoming, bool hasIncoming) {
  final clean = incoming.trim();
  return hasIncoming ? (clean.isEmpty ? null : clean) : existing;
}

int? _normalizeAircraftMtow({
  required int? aircraftMtow,
  required int typeMtow,
}) {
  if (aircraftMtow == null || aircraftMtow <= 0) return null;
  if (typeMtow > 0 && aircraftMtow == typeMtow) {
    return null;
  }
  return aircraftMtow;
}
