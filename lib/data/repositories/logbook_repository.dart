// ignore_for_file: annotate_overrides

import 'dart:async';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/duty_edit_data.dart';
import '../models/flight_edit_data.dart';
import '../models/flight_write_input.dart';
import '../models/logbook_entry.dart';
import '../models/logbook_filters.dart';
import '../models/positioning_edit_data.dart';
import '../models/simulator_crew_assignment_input.dart';
import '../models/simulator_edit_data.dart';
import '../../domain/repositories/logbook_repository_contract.dart';

class LogbookRepository implements LogbookRepositoryContract {
  LogbookRepository(this._db);

  final AppDatabase _db;

  Future<void> toggleEntryLock(LogbookEntry entry) async {
    switch (entry.type) {
      case LogbookEventType.flight:
        final item = entry.flight;
        if (item == null) return;
        await _db
            .update(_db.flights)
            .replace(item.copyWith(isLocked: !item.isLocked));
        return;
      case LogbookEventType.simulatorTraining:
        final item = entry.simulatorTraining;
        if (item == null) return;
        await _db
            .update(_db.simulatorTrainings)
            .replace(item.copyWith(isLocked: !item.isLocked));
        return;
      case LogbookEventType.positioning:
        final item = entry.positioning;
        if (item == null) return;
        await _db
            .update(_db.positionings)
            .replace(item.copyWith(isLocked: !item.isLocked));
        return;
      case LogbookEventType.dutyPeriod:
        final item = entry.dutyStart ?? entry.dutyEnd;
        if (item == null) return;
        await _db
            .update(_db.dutyPeriods)
            .replace(item.copyWith(isLocked: !item.isLocked));
        return;
      case LogbookEventType.unknown:
        return;
    }
  }

  Future<void> toggleDutyLock(int dutyId) async {
    final duty = await findDutyById(dutyId);
    if (duty == null) return;
    await _db
        .update(_db.dutyPeriods)
        .replace(duty.copyWith(isLocked: !duty.isLocked));
  }

  Future<DutyPeriod?> findDutyById(int dutyId) async {
    return (_db.select(
      _db.dutyPeriods,
    )..where((t) => t.id.equals(dutyId))).getSingleOrNull();
  }

  Future<Flight?> findFlightById(int flightId) async {
    return (_db.select(
      _db.flights,
    )..where((t) => t.id.equals(flightId))).getSingleOrNull();
  }

  Future<FlightEditData?> loadFlightEditData(int flightId) async {
    final flight = await findFlightById(flightId);
    if (flight == null) return null;
    final departureLine = await (_db.select(
      _db.timeLines,
    )..where((t) => t.id.equals(flight.departureDateTimeId))).getSingleOrNull();
    return FlightEditData(
      flight: flight,
      departureLine: _normalizeTimeLine(departureLine),
      crewAssignments: await fetchFlightCrewAssignments(flightId),
    );
  }

  Future<List<FlightCrewAssignment>> fetchFlightCrewAssignments(int flightId) {
    return (_db.select(
      _db.flightCrewAssignments,
    )..where((t) => t.flightId.equals(flightId))).get();
  }

  Future<DutyEditData?> loadDutyEditData(int dutyId) async {
    final duty = await findDutyById(dutyId);
    if (duty == null) return null;
    final startLine =
        await (_db.select(_db.timeLines)
              ..where((tbl) => tbl.id.equals(duty.dutyStartTimeLineId)))
            .getSingleOrNull();
    final endLine = await (_db.select(
      _db.timeLines,
    )..where((tbl) => tbl.id.equals(duty.dutyEndTimeLineId))).getSingleOrNull();
    return DutyEditData(
      duty: duty,
      startLine: _normalizeTimeLine(startLine),
      endLine: _normalizeTimeLine(endLine),
    );
  }

  Future<Positioning?> findPositioningById(int positioningId) async {
    return (_db.select(
      _db.positionings,
    )..where((t) => t.id.equals(positioningId))).getSingleOrNull();
  }

  Future<PositioningEditData?> loadPositioningEditData(
    int positioningId,
  ) async {
    final positioning = await findPositioningById(positioningId);
    if (positioning == null) return null;
    final departureLine =
        await (_db.select(_db.timeLines)
              ..where((t) => t.id.equals(positioning.departureDateTimeId)))
            .getSingleOrNull();
    return PositioningEditData(
      positioning: positioning,
      departureLine: _normalizeTimeLine(departureLine),
    );
  }

  Future<SimulatorTraining?> findSimulatorTrainingById(int simulatorId) async {
    return (_db.select(
      _db.simulatorTrainings,
    )..where((t) => t.id.equals(simulatorId))).getSingleOrNull();
  }

  Future<SimulatorEditData?> loadSimulatorEditData(int simulatorId) async {
    final simulatorTraining = await findSimulatorTrainingById(simulatorId);
    if (simulatorTraining == null) return null;
    final startLine =
        await (_db.select(_db.timeLines)
              ..where((t) => t.id.equals(simulatorTraining.startTimeLineId)))
            .getSingleOrNull();
    return SimulatorEditData(
      simulatorTraining: simulatorTraining,
      startLine: _normalizeTimeLine(startLine),
      crewAssignments: await fetchSimulatorCrewAssignments(simulatorId),
    );
  }

  Future<List<SimulatorCrewAssignment>> fetchSimulatorCrewAssignments(
    int simulatorId,
  ) {
    return (_db.select(
      _db.simulatorCrewAssignments,
    )..where((t) => t.simulatorId.equals(simulatorId))).get();
  }

  Future<void> createDuty({
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  }) async {
    await _db.transaction(() async {
      final startId = await _db
          .into(_db.timeLines)
          .insert(TimeLinesCompanion.insert(eventDateTime: start));
      final endId = await _db
          .into(_db.timeLines)
          .insert(TimeLinesCompanion.insert(eventDateTime: end));
      await _db
          .into(_db.dutyPeriods)
          .insert(
            DutyPeriodsCompanion.insert(
              dutyStartTimeLineId: startId,
              dutyEndTimeLineId: endId,
              timeDutyMinutes: dutyMinutes,
              timeFactoredDutyMinutes: factoredMinutes,
              isLocked: false,
            ),
          );
    });
  }

  Future<void> updateDuty({
    required DutyPeriod duty,
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  }) async {
    await _db.transaction(() async {
      final startLine = await (_db.select(
        _db.timeLines,
      )..where((tbl) => tbl.id.equals(duty.dutyStartTimeLineId))).getSingle();
      final endLine = await (_db.select(
        _db.timeLines,
      )..where((tbl) => tbl.id.equals(duty.dutyEndTimeLineId))).getSingle();
      await _db
          .update(_db.timeLines)
          .replace(startLine.copyWith(eventDateTime: start));
      await _db
          .update(_db.timeLines)
          .replace(endLine.copyWith(eventDateTime: end));
      await _db
          .update(_db.dutyPeriods)
          .replace(
            duty.copyWith(
              timeDutyMinutes: dutyMinutes,
              timeFactoredDutyMinutes: factoredMinutes,
            ),
          );
    });
  }

  Future<void> createPositioning({
    required int departureAirportId,
    required int arrivalAirportId,
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int totalMinutes,
    required String notes,
  }) async {
    await _db.transaction(() async {
      final departureTimelineId = await _db
          .into(_db.timeLines)
          .insert(TimeLinesCompanion.insert(eventDateTime: departureDateTime));
      await _db
          .into(_db.positionings)
          .insert(
            PositioningsCompanion.insert(
              departurePlaceId: departureAirportId,
              arrivalPlaceId: arrivalAirportId,
              departureDateTimeId: departureTimelineId,
              arrivalDateTime: Value(arrivalDateTime),
              timeTotalMinutes: totalMinutes,
              notes: Value(notes),
              isLocked: false,
            ),
          );
    });
  }

  Future<void> createFlight({
    required FlightWriteInput input,
  }) async {
    await _db.transaction(() async {
      final departureTimelineId = await _db
          .into(_db.timeLines)
          .insert(TimeLinesCompanion.insert(eventDateTime: input.departureDateTime));
      final flightId = await _db
          .into(_db.flights)
          .insert(
            FlightsCompanion.insert(
              aircraftId: input.aircraftId,
              departureAirportId: input.departureAirportId,
              arrivalAirportId: input.arrivalAirportId,
              departureDateTimeId: departureTimelineId,
              takeOffDateTime: Value(input.takeOffDateTime),
              landingDateTime: Value(input.landingDateTime),
              arrivalDateTime: Value(input.arrivalDateTime),
              timePICMinutes: input.timePICMinutes,
              timePICUSMinutes: input.timePICUSMinutes,
              timeSICMinutes: input.timeSICMinutes,
              timeDualMinutes: input.timeDualMinutes,
              timeInstructorMinutes: input.timeInstructorMinutes,
              timeIFRMinutes: input.timeIFRMinutes,
              timeInstrumentMinutes: input.timeInstrumentMinutes,
              timeSimulatedInstrumentMinutes: input.timeSimulatedInstrumentMinutes,
              timeNightMinutes: input.timeNightMinutes,
              timeCrossCountryMinutes: input.timeCrossCountryMinutes,
              timeCustom1Minutes: input.timeCustom1Minutes,
              timeCustom2Minutes: input.timeCustom2Minutes,
              timeCustom3Minutes: input.timeCustom3Minutes,
              timeCustom4Minutes: input.timeCustom4Minutes,
              timeFlightMinutes: input.timeFlightMinutes,
              timeBlockMinutes: input.timeBlockMinutes,
              distanceNM: input.distanceNM,
              ifrApproaches: input.ifrApproaches,
              takeOffsDays: input.takeOffsDays,
              takeOffsNight: input.takeOffsNight,
              landingsDay: input.landingsDay,
              landingsNight: input.landingsNight,
              pilotFunction: Value(input.pilotFunction),
              approachType: input.approachType,
              remarks: input.remarks,
              notes: input.notes,
              timeTotalBlockMinutes: Value(input.timeTotalBlockMinutes),
              isLocked: false,
              signatureImage: const Value(null),
            ),
          );
      await _replaceFlightCrewAssignments(flightId, input.crewAssignments);
    });
  }

  Future<void> updateFlight({
    required Flight flight,
    required FlightWriteInput input,
  }) async {
    await _db.transaction(() async {
      final departureLine = await (_db.select(
        _db.timeLines,
      )..where((t) => t.id.equals(flight.departureDateTimeId))).getSingle();
      await _db
          .update(_db.timeLines)
          .replace(departureLine.copyWith(eventDateTime: input.departureDateTime));
      await _db
          .update(_db.flights)
          .replace(
            flight.copyWith(
              aircraftId: input.aircraftId,
              departureAirportId: input.departureAirportId,
              arrivalAirportId: input.arrivalAirportId,
              takeOffDateTime: Value(input.takeOffDateTime),
              landingDateTime: Value(input.landingDateTime),
              arrivalDateTime: Value(input.arrivalDateTime),
              timePICMinutes: input.timePICMinutes,
              timePICUSMinutes: input.timePICUSMinutes,
              timeSICMinutes: input.timeSICMinutes,
              timeDualMinutes: input.timeDualMinutes,
              timeInstructorMinutes: input.timeInstructorMinutes,
              timeIFRMinutes: input.timeIFRMinutes,
              timeInstrumentMinutes: input.timeInstrumentMinutes,
              timeSimulatedInstrumentMinutes: input.timeSimulatedInstrumentMinutes,
              timeNightMinutes: input.timeNightMinutes,
              timeCrossCountryMinutes: input.timeCrossCountryMinutes,
              timeCustom1Minutes: input.timeCustom1Minutes,
              timeCustom2Minutes: input.timeCustom2Minutes,
              timeCustom3Minutes: input.timeCustom3Minutes,
              timeCustom4Minutes: input.timeCustom4Minutes,
              timeFlightMinutes: input.timeFlightMinutes,
              timeBlockMinutes: input.timeBlockMinutes,
              distanceNM: input.distanceNM,
              ifrApproaches: input.ifrApproaches,
              takeOffsDays: input.takeOffsDays,
              takeOffsNight: input.takeOffsNight,
              landingsDay: input.landingsDay,
              landingsNight: input.landingsNight,
              pilotFunction: input.pilotFunction,
              approachType: input.approachType,
              remarks: input.remarks,
              notes: input.notes,
              timeTotalBlockMinutes: input.timeTotalBlockMinutes,
            ),
          );
      await _replaceFlightCrewAssignments(flight.id, input.crewAssignments);
    });
  }

  Future<void> updatePositioning({
    required Positioning positioning,
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int departureAirportId,
    required int arrivalAirportId,
    required int totalMinutes,
    required String notes,
  }) async {
    await _db.transaction(() async {
      final departureLine =
          await (_db.select(_db.timeLines)
                ..where((t) => t.id.equals(positioning.departureDateTimeId)))
              .getSingle();
      await _db
          .update(_db.timeLines)
          .replace(departureLine.copyWith(eventDateTime: departureDateTime));
      await _db
          .update(_db.positionings)
          .replace(
            positioning.copyWith(
              departurePlaceId: departureAirportId,
              arrivalPlaceId: arrivalAirportId,
              arrivalDateTime: Value(arrivalDateTime),
              timeTotalMinutes: totalMinutes,
              notes: notes,
            ),
          );
    });
  }

  Future<void> createSimulatorTraining({
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
  }) async {
    await _db.transaction(() async {
      final startTimelineId = await _db
          .into(_db.timeLines)
          .insert(TimeLinesCompanion.insert(eventDateTime: startDateTime));
      final simulatorId = await _db
          .into(_db.simulatorTrainings)
          .insert(
            SimulatorTrainingsCompanion.insert(
              aircraftId: aircraftId,
              startTimeLineId: startTimelineId,
              endDateTime: Value(endDateTime),
              timeTotal: totalMinutes,
              remarks: remarks,
              notes: notes,
              isLocked: false,
              signatureImage: const Value(null),
            ),
          );
      await _replaceSimulatorCrewAssignments(simulatorId, crewAssignments);
    });
  }

  Future<void> updateSimulatorTraining({
    required SimulatorTraining simulatorTraining,
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
  }) async {
    await _db.transaction(() async {
      final startLine =
          await (_db.select(_db.timeLines)
                ..where((t) => t.id.equals(simulatorTraining.startTimeLineId)))
              .getSingle();
      await _db
          .update(_db.timeLines)
          .replace(startLine.copyWith(eventDateTime: startDateTime));
      await _db
          .update(_db.simulatorTrainings)
          .replace(
            simulatorTraining.copyWith(
              aircraftId: aircraftId,
              endDateTime: Value(endDateTime),
              timeTotal: totalMinutes,
              remarks: remarks,
              notes: notes,
            ),
          );
      await _replaceSimulatorCrewAssignments(
        simulatorTraining.id,
        crewAssignments,
      );
    });
  }

  Future<void> _replaceSimulatorCrewAssignments(
    int simulatorId,
    List<SimulatorCrewAssignmentInput> assignments,
  ) async {
    await (_db.delete(
      _db.simulatorCrewAssignments,
    )..where((t) => t.simulatorId.equals(simulatorId))).go();
    if (assignments.isEmpty) return;
    for (final assignment in assignments) {
      await _db
          .into(_db.simulatorCrewAssignments)
          .insert(
            SimulatorCrewAssignmentsCompanion.insert(
              simulatorId: simulatorId,
              crewId: assignment.crewId,
              position: assignment.position,
            ),
          );
    }
  }

  Future<void> _replaceFlightCrewAssignments(
    int flightId,
    List<SimulatorCrewAssignmentInput> assignments,
  ) async {
    await (_db.delete(
      _db.flightCrewAssignments,
    )..where((t) => t.flightId.equals(flightId))).go();
    if (assignments.isEmpty) return;
    for (final assignment in assignments) {
      await _db
          .into(_db.flightCrewAssignments)
          .insert(
            FlightCrewAssignmentsCompanion.insert(
              flightId: flightId,
              crewId: assignment.crewId,
              position: assignment.position,
            ),
          );
    }
  }

  Future<List<String>> fetchFlightCrewLabels(int flightId) async {
    final rows = await (_db.select(_db.flightCrewAssignments).join([
      innerJoin(
        _db.crew,
        _db.crew.id.equalsExp(_db.flightCrewAssignments.crewId),
      ),
    ])..where(_db.flightCrewAssignments.flightId.equals(flightId))).get();
    return rows.map((row) {
      final crew = row.readTable(_db.crew);
      final assignment = row.readTable(_db.flightCrewAssignments);
      return '${assignment.position.name.toUpperCase()}: ${crew.name}';
    }).toList();
  }

  Future<List<String>> fetchSimulatorCrewLabels(int simulatorId) async {
    final rows =
        await (_db.select(_db.simulatorCrewAssignments).join([
              innerJoin(
                _db.crew,
                _db.crew.id.equalsExp(_db.simulatorCrewAssignments.crewId),
              ),
            ])..where(
              _db.simulatorCrewAssignments.simulatorId.equals(simulatorId),
            ))
            .get();
    return rows.map((row) {
      final crew = row.readTable(_db.crew);
      final assignment = row.readTable(_db.simulatorCrewAssignments);
      return '${assignment.position.name.toUpperCase()}: ${crew.name}';
    }).toList();
  }

  Future<List<LogbookEntry>> fetchEntriesForAirport(int airportId) async {
    final dep = _db.alias(_db.airports, 'dep');
    final arr = _db.alias(_db.airports, 'arr');
    final posDep = _db.alias(_db.airports, 'pos_dep');
    final posArr = _db.alias(_db.airports, 'pos_arr');

    final flightQuery =
        _db.select(_db.flights).join([
          innerJoin(
            _db.timeLines,
            _db.timeLines.id.equalsExp(_db.flights.departureDateTimeId),
          ),
          leftOuterJoin(
            _db.aircrafts,
            _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
          ),
          leftOuterJoin(
            _db.aircraftTypes,
            _db.aircraftTypes.id.equalsExp(_db.aircrafts.aircraftTypeId),
          ),
          leftOuterJoin(dep, dep.id.equalsExp(_db.flights.departureAirportId)),
          leftOuterJoin(arr, arr.id.equalsExp(_db.flights.arrivalAirportId)),
        ])..where(
          _db.flights.departureAirportId.equals(airportId) |
              _db.flights.arrivalAirportId.equals(airportId),
        );

    final positioningQuery =
        _db.select(_db.positionings).join([
          innerJoin(
            _db.timeLines,
            _db.timeLines.id.equalsExp(_db.positionings.departureDateTimeId),
          ),
          leftOuterJoin(
            posDep,
            posDep.id.equalsExp(_db.positionings.departurePlaceId),
          ),
          leftOuterJoin(
            posArr,
            posArr.id.equalsExp(_db.positionings.arrivalPlaceId),
          ),
        ])..where(
          _db.positionings.departurePlaceId.equals(airportId) |
              _db.positionings.arrivalPlaceId.equals(airportId),
        );

    final flightRows = await flightQuery.get();
    final positioningRows = await positioningQuery.get();
    final entries = <LogbookEntry>[];

    for (final row in flightRows) {
      entries.add(
        LogbookEntry(
          timeLine: _normalizeTimeLine(row.readTable(_db.timeLines))!,
          flight: row.readTable(_db.flights),
          aircraft: row.readTableOrNull(_db.aircrafts),
          aircraftType: row.readTableOrNull(_db.aircraftTypes),
          departureAirport: row.readTableOrNull(dep),
          arrivalAirport: row.readTableOrNull(arr),
        ),
      );
    }
    for (final row in positioningRows) {
      entries.add(
        LogbookEntry(
          timeLine: _normalizeTimeLine(row.readTable(_db.timeLines))!,
          positioning: row.readTable(_db.positionings),
          positioningDepartureAirport: row.readTableOrNull(posDep),
          positioningArrivalAirport: row.readTableOrNull(posArr),
        ),
      );
    }
    entries.sort(
      (a, b) => b.timeLine.eventDateTime.compareTo(a.timeLine.eventDateTime),
    );
    return entries;
  }

  Future<List<LogbookEntry>> fetchEntriesForAircraft(int aircraftId) async {
    final dep = _db.alias(_db.airports, 'dep');
    final arr = _db.alias(_db.airports, 'arr');
    final simAircraft = _db.alias(_db.aircrafts, 'sim_aircrafts');
    final simType = _db.alias(_db.aircraftTypes, 'sim_aircraft_types');

    final flightQuery = _db.select(_db.flights).join([
      innerJoin(
        _db.timeLines,
        _db.timeLines.id.equalsExp(_db.flights.departureDateTimeId),
      ),
      leftOuterJoin(
        _db.aircrafts,
        _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
      ),
      leftOuterJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.aircrafts.aircraftTypeId),
      ),
      leftOuterJoin(dep, dep.id.equalsExp(_db.flights.departureAirportId)),
      leftOuterJoin(arr, arr.id.equalsExp(_db.flights.arrivalAirportId)),
    ])..where(_db.flights.aircraftId.equals(aircraftId));

    final simQuery = _db.select(_db.simulatorTrainings).join([
      innerJoin(
        _db.timeLines,
        _db.timeLines.id.equalsExp(_db.simulatorTrainings.startTimeLineId),
      ),
      leftOuterJoin(
        simAircraft,
        simAircraft.id.equalsExp(_db.simulatorTrainings.aircraftId),
      ),
      leftOuterJoin(simType, simType.id.equalsExp(simAircraft.aircraftTypeId)),
    ])..where(_db.simulatorTrainings.aircraftId.equals(aircraftId));

    final flightRows = await flightQuery.get();
    final simRows = await simQuery.get();
    final entries = <LogbookEntry>[];

    for (final row in flightRows) {
      entries.add(
        LogbookEntry(
          timeLine: _normalizeTimeLine(row.readTable(_db.timeLines))!,
          flight: row.readTable(_db.flights),
          aircraft: row.readTableOrNull(_db.aircrafts),
          aircraftType: row.readTableOrNull(_db.aircraftTypes),
          departureAirport: row.readTableOrNull(dep),
          arrivalAirport: row.readTableOrNull(arr),
        ),
      );
    }
    for (final row in simRows) {
      entries.add(
        LogbookEntry(
          timeLine: _normalizeTimeLine(row.readTable(_db.timeLines))!,
          simulatorTraining: row.readTable(_db.simulatorTrainings),
          aircraft: row.readTableOrNull(simAircraft),
          aircraftType: row.readTableOrNull(simType),
        ),
      );
    }
    entries.sort(
      (a, b) => b.timeLine.eventDateTime.compareTo(a.timeLine.eventDateTime),
    );
    return entries;
  }

  Future<List<LogbookEntry>> fetchEntriesForAircraftType(
    int aircraftTypeId,
  ) async {
    final dep = _db.alias(_db.airports, 'dep');
    final arr = _db.alias(_db.airports, 'arr');
    final simAircraft = _db.alias(_db.aircrafts, 'sim_aircrafts');
    final simType = _db.alias(_db.aircraftTypes, 'sim_aircraft_types');

    final flightQuery = _db.select(_db.flights).join([
      innerJoin(
        _db.timeLines,
        _db.timeLines.id.equalsExp(_db.flights.departureDateTimeId),
      ),
      innerJoin(
        _db.aircrafts,
        _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
      ),
      innerJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.aircrafts.aircraftTypeId),
      ),
      leftOuterJoin(dep, dep.id.equalsExp(_db.flights.departureAirportId)),
      leftOuterJoin(arr, arr.id.equalsExp(_db.flights.arrivalAirportId)),
    ])..where(_db.aircrafts.aircraftTypeId.equals(aircraftTypeId));

    final simQuery = _db.select(_db.simulatorTrainings).join([
      innerJoin(
        _db.timeLines,
        _db.timeLines.id.equalsExp(_db.simulatorTrainings.startTimeLineId),
      ),
      innerJoin(
        simAircraft,
        simAircraft.id.equalsExp(_db.simulatorTrainings.aircraftId),
      ),
      innerJoin(simType, simType.id.equalsExp(simAircraft.aircraftTypeId)),
    ])..where(simAircraft.aircraftTypeId.equals(aircraftTypeId));

    final flightRows = await flightQuery.get();
    final simRows = await simQuery.get();
    final entries = <LogbookEntry>[];

    for (final row in flightRows) {
      entries.add(
        LogbookEntry(
          timeLine: _normalizeTimeLine(row.readTable(_db.timeLines))!,
          flight: row.readTable(_db.flights),
          aircraft: row.readTableOrNull(_db.aircrafts),
          aircraftType: row.readTableOrNull(_db.aircraftTypes),
          departureAirport: row.readTableOrNull(dep),
          arrivalAirport: row.readTableOrNull(arr),
        ),
      );
    }
    for (final row in simRows) {
      entries.add(
        LogbookEntry(
          timeLine: _normalizeTimeLine(row.readTable(_db.timeLines))!,
          simulatorTraining: row.readTable(_db.simulatorTrainings),
          aircraft: row.readTableOrNull(simAircraft),
          aircraftType: row.readTableOrNull(simType),
        ),
      );
    }
    entries.sort(
      (a, b) => b.timeLine.eventDateTime.compareTo(a.timeLine.eventDateTime),
    );
    return entries;
  }

  Future<List<LogbookEntry>> fetchEntriesForCrew(int crewId) async {
    final dep = _db.alias(_db.airports, 'dep');
    final arr = _db.alias(_db.airports, 'arr');
    final simAircraft = _db.alias(_db.aircrafts, 'sim_aircrafts');
    final simType = _db.alias(_db.aircraftTypes, 'sim_aircraft_types');

    final flightQuery = _db.select(_db.flights).join([
      innerJoin(
        _db.flightCrewAssignments,
        _db.flightCrewAssignments.flightId.equalsExp(_db.flights.id),
      ),
      innerJoin(
        _db.timeLines,
        _db.timeLines.id.equalsExp(_db.flights.departureDateTimeId),
      ),
      leftOuterJoin(
        _db.aircrafts,
        _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
      ),
      leftOuterJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.aircrafts.aircraftTypeId),
      ),
      leftOuterJoin(dep, dep.id.equalsExp(_db.flights.departureAirportId)),
      leftOuterJoin(arr, arr.id.equalsExp(_db.flights.arrivalAirportId)),
    ])..where(_db.flightCrewAssignments.crewId.equals(crewId));

    final simQuery = _db.select(_db.simulatorTrainings).join([
      innerJoin(
        _db.simulatorCrewAssignments,
        _db.simulatorCrewAssignments.simulatorId.equalsExp(
          _db.simulatorTrainings.id,
        ),
      ),
      innerJoin(
        _db.timeLines,
        _db.timeLines.id.equalsExp(_db.simulatorTrainings.startTimeLineId),
      ),
      leftOuterJoin(
        simAircraft,
        simAircraft.id.equalsExp(_db.simulatorTrainings.aircraftId),
      ),
      leftOuterJoin(simType, simType.id.equalsExp(simAircraft.aircraftTypeId)),
    ])..where(_db.simulatorCrewAssignments.crewId.equals(crewId));

    final flightRows = await flightQuery.get();
    final simRows = await simQuery.get();
    final entries = <LogbookEntry>[];

    for (final row in flightRows) {
      entries.add(
        LogbookEntry(
          timeLine: _normalizeTimeLine(row.readTable(_db.timeLines))!,
          flight: row.readTable(_db.flights),
          aircraft: row.readTableOrNull(_db.aircrafts),
          aircraftType: row.readTableOrNull(_db.aircraftTypes),
          departureAirport: row.readTableOrNull(dep),
          arrivalAirport: row.readTableOrNull(arr),
        ),
      );
    }
    for (final row in simRows) {
      entries.add(
        LogbookEntry(
          timeLine: _normalizeTimeLine(row.readTable(_db.timeLines))!,
          simulatorTraining: row.readTable(_db.simulatorTrainings),
          aircraft: row.readTableOrNull(simAircraft),
          aircraftType: row.readTableOrNull(simType),
        ),
      );
    }
    entries.sort(
      (a, b) => b.timeLine.eventDateTime.compareTo(a.timeLine.eventDateTime),
    );
    return entries;
  }

  Future<void> deleteEntry(LogbookEntry entry) async {
    switch (entry.type) {
      case LogbookEventType.flight:
        final flight = entry.flight;
        if (flight == null) return;
        await _db.transaction(() async {
          await (_db.delete(
            _db.flightCrewAssignments,
          )..where((t) => t.flightId.equals(flight.id))).go();
          await (_db.delete(
            _db.flights,
          )..where((t) => t.id.equals(flight.id))).go();
          await (_db.delete(
            _db.timeLines,
          )..where((t) => t.id.equals(flight.departureDateTimeId))).go();
        });
        return;
      case LogbookEventType.simulatorTraining:
        final sim = entry.simulatorTraining;
        if (sim == null) return;
        await _db.transaction(() async {
          await (_db.delete(
            _db.simulatorCrewAssignments,
          )..where((t) => t.simulatorId.equals(sim.id))).go();
          await (_db.delete(
            _db.simulatorTrainings,
          )..where((t) => t.id.equals(sim.id))).go();
          await (_db.delete(
            _db.timeLines,
          )..where((t) => t.id.equals(sim.startTimeLineId))).go();
        });
        return;
      case LogbookEventType.positioning:
        final positioning = entry.positioning;
        if (positioning == null) return;
        await _db.transaction(() async {
          await (_db.delete(
            _db.positionings,
          )..where((t) => t.id.equals(positioning.id))).go();
          await (_db.delete(
            _db.timeLines,
          )..where((t) => t.id.equals(positioning.departureDateTimeId))).go();
        });
        return;
      case LogbookEventType.dutyPeriod:
        final duty = entry.dutyStart ?? entry.dutyEnd;
        if (duty == null) return;
        await deleteDutyById(duty.id);
        return;
      case LogbookEventType.unknown:
        return;
    }
  }

  Future<void> deleteDutyById(int dutyId) async {
    final duty = await findDutyById(dutyId);
    if (duty == null) return;
    await _db.transaction(() async {
      await (_db.delete(
        _db.dutyPeriods,
      )..where((t) => t.id.equals(duty.id))).go();
      final ids = <int>{duty.dutyStartTimeLineId, duty.dutyEndTimeLineId};
      for (final id in ids) {
        await (_db.delete(_db.timeLines)..where((t) => t.id.equals(id))).go();
      }
    });
  }

  Stream<List<LogbookEntry>> watchLogbook(LogbookFilters filters) {
    if (filters.types.isEmpty) {
      return Stream.value(<LogbookEntry>[]);
    }

    final departureAirport = _db.alias(_db.airports, 'departure_airports');
    final arrivalAirport = _db.alias(_db.airports, 'arrival_airports');
    final positioningDeparture = _db.alias(
      _db.airports,
      'positioning_departure',
    );
    final positioningArrival = _db.alias(_db.airports, 'positioning_arrival');
    final dutyStart = _db.alias(_db.dutyPeriods, 'duty_start');
    final dutyEnd = _db.alias(_db.dutyPeriods, 'duty_end');
    final simAircraft = _db.alias(_db.aircrafts, 'sim_aircrafts');
    final simAircraftType = _db.alias(_db.aircraftTypes, 'sim_aircraft_types');

    final query = _buildQuery(
      filters,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    );

    return query.watch().map((rows) {
      return _mapRows(
        rows,
        departureAirport: departureAirport,
        arrivalAirport: arrivalAirport,
        positioningDeparture: positioningDeparture,
        positioningArrival: positioningArrival,
        dutyStart: dutyStart,
        dutyEnd: dutyEnd,
        simAircraft: simAircraft,
        simAircraftType: simAircraftType,
      );
    });
  }

  Future<LogbookEntry?> fetchEntryByTimelineId(int timeLineId) async {
    final departureAirport = _db.alias(_db.airports, 'departure_airports');
    final arrivalAirport = _db.alias(_db.airports, 'arrival_airports');
    final positioningDeparture = _db.alias(
      _db.airports,
      'positioning_departure',
    );
    final positioningArrival = _db.alias(_db.airports, 'positioning_arrival');
    final dutyStart = _db.alias(_db.dutyPeriods, 'duty_start');
    final dutyEnd = _db.alias(_db.dutyPeriods, 'duty_end');
    final simAircraft = _db.alias(_db.aircrafts, 'sim_aircrafts');
    final simAircraftType = _db.alias(_db.aircraftTypes, 'sim_aircraft_types');

    final query = _buildBaseQuery(
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    )..where(_db.timeLines.id.equals(timeLineId));

    final rows = await query.get();
    if (rows.isEmpty) return null;
    final mapped = _mapRows(
      rows,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    );
    return mapped.isEmpty ? null : mapped.first;
  }

  Future<List<LogbookEntry>> fetchLogbookPage(
    LogbookFilters filters, {
    required int limit,
    required int offset,
  }) async {
    if (filters.types.isEmpty) {
      return <LogbookEntry>[];
    }
    final departureAirport = _db.alias(_db.airports, 'departure_airports');
    final arrivalAirport = _db.alias(_db.airports, 'arrival_airports');
    final positioningDeparture = _db.alias(
      _db.airports,
      'positioning_departure',
    );
    final positioningArrival = _db.alias(_db.airports, 'positioning_arrival');
    final dutyStart = _db.alias(_db.dutyPeriods, 'duty_start');
    final dutyEnd = _db.alias(_db.dutyPeriods, 'duty_end');
    final simAircraft = _db.alias(_db.aircrafts, 'sim_aircrafts');
    final simAircraftType = _db.alias(_db.aircraftTypes, 'sim_aircraft_types');

    final query = _buildQuery(
      filters,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    );
    query.limit(limit, offset: offset);

    final rows = await query.get();
    return _mapRows(
      rows,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    );
  }

  JoinedSelectStatement _buildBaseQuery({
    required $AirportsTable departureAirport,
    required $AirportsTable arrivalAirport,
    required $AirportsTable positioningDeparture,
    required $AirportsTable positioningArrival,
    required $DutyPeriodsTable dutyStart,
    required $DutyPeriodsTable dutyEnd,
    required $AircraftsTable simAircraft,
    required $AircraftTypesTable simAircraftType,
  }) {
    final query = _db.select(_db.timeLines).join([
      leftOuterJoin(
        _db.flights,
        _db.flights.departureDateTimeId.equalsExp(_db.timeLines.id),
      ),
      leftOuterJoin(
        _db.aircrafts,
        _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
      ),
      leftOuterJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.aircrafts.aircraftTypeId),
      ),
      leftOuterJoin(
        departureAirport,
        departureAirport.id.equalsExp(_db.flights.departureAirportId),
      ),
      leftOuterJoin(
        arrivalAirport,
        arrivalAirport.id.equalsExp(_db.flights.arrivalAirportId),
      ),
      leftOuterJoin(
        _db.positionings,
        _db.positionings.departureDateTimeId.equalsExp(_db.timeLines.id),
      ),
      leftOuterJoin(
        positioningDeparture,
        positioningDeparture.id.equalsExp(_db.positionings.departurePlaceId),
      ),
      leftOuterJoin(
        positioningArrival,
        positioningArrival.id.equalsExp(_db.positionings.arrivalPlaceId),
      ),
      leftOuterJoin(
        dutyStart,
        dutyStart.dutyStartTimeLineId.equalsExp(_db.timeLines.id),
      ),
      leftOuterJoin(
        dutyEnd,
        dutyEnd.dutyEndTimeLineId.equalsExp(_db.timeLines.id),
      ),
      leftOuterJoin(
        _db.simulatorTrainings,
        _db.simulatorTrainings.startTimeLineId.equalsExp(_db.timeLines.id),
      ),
      leftOuterJoin(
        simAircraft,
        simAircraft.id.equalsExp(_db.simulatorTrainings.aircraftId),
      ),
      leftOuterJoin(
        simAircraftType,
        simAircraftType.id.equalsExp(simAircraft.aircraftTypeId),
      ),
    ]);
    return query;
  }

  JoinedSelectStatement _buildQuery(
    LogbookFilters filters, {
    required $AirportsTable departureAirport,
    required $AirportsTable arrivalAirport,
    required $AirportsTable positioningDeparture,
    required $AirportsTable positioningArrival,
    required $DutyPeriodsTable dutyStart,
    required $DutyPeriodsTable dutyEnd,
    required $AircraftsTable simAircraft,
    required $AircraftTypesTable simAircraftType,
  }) {
    final query = _buildBaseQuery(
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    );

    if (filters.from != null) {
      query.where(
        _db.timeLines.eventDateTime.isBiggerOrEqualValue(filters.from!),
      );
    }
    if (filters.to != null) {
      query.where(
        _db.timeLines.eventDateTime.isSmallerOrEqualValue(filters.to!),
      );
    }
    query.where(_typesPredicate(filters.types, dutyStart, dutyEnd));

    query.orderBy([
      OrderingTerm.desc(_db.timeLines.eventDateTime),
      OrderingTerm.desc(_db.timeLines.id),
    ]);

    return query;
  }

  List<LogbookEntry> _mapRows(
    List<TypedResult> rows, {
    required $AirportsTable departureAirport,
    required $AirportsTable arrivalAirport,
    required $AirportsTable positioningDeparture,
    required $AirportsTable positioningArrival,
    required $DutyPeriodsTable dutyStart,
    required $DutyPeriodsTable dutyEnd,
    required $AircraftsTable simAircraft,
    required $AircraftTypesTable simAircraftType,
  }) {
    return rows.map((row) {
      final flightAircraft = row.readTableOrNull(_db.aircrafts);
      final simAircraftRow = row.readTableOrNull(simAircraft);
      final flightType = row.readTableOrNull(_db.aircraftTypes);
      final simType = row.readTableOrNull(simAircraftType);
      final aircraft = flightAircraft ?? simAircraftRow;
      final aircraftType = flightType ?? simType;
      return LogbookEntry(
        timeLine: _normalizeTimeLine(row.readTable(_db.timeLines))!,
        flight: row.readTableOrNull(_db.flights),
        aircraft: aircraft,
        aircraftType: aircraftType,
        positioning: row.readTableOrNull(_db.positionings),
        simulatorTraining: row.readTableOrNull(_db.simulatorTrainings),
        dutyStart: row.readTableOrNull(dutyStart),
        dutyEnd: row.readTableOrNull(dutyEnd),
        departureAirport: row.readTableOrNull(departureAirport),
        arrivalAirport: row.readTableOrNull(arrivalAirport),
        positioningDepartureAirport: row.readTableOrNull(positioningDeparture),
        positioningArrivalAirport: row.readTableOrNull(positioningArrival),
      );
    }).toList();
  }

  Expression<bool> _typesPredicate(
    Set<LogbookEventType> types,
    $DutyPeriodsTable dutyStart,
    $DutyPeriodsTable dutyEnd,
  ) {
    final clauses = <Expression<bool>>[];
    if (types.contains(LogbookEventType.flight)) {
      clauses.add(_db.flights.id.isNotNull());
    }
    if (types.contains(LogbookEventType.positioning)) {
      clauses.add(_db.positionings.id.isNotNull());
    }
    if (types.contains(LogbookEventType.simulatorTraining)) {
      clauses.add(_db.simulatorTrainings.id.isNotNull());
    }
    if (types.contains(LogbookEventType.dutyPeriod)) {
      clauses.add(dutyStart.id.isNotNull() | dutyEnd.id.isNotNull());
    }
    return clauses.reduce((value, element) => value | element);
  }

  TimeLine? _normalizeTimeLine(TimeLine? row) {
    return row;
  }

  Future<DateTime?> fetchFirstEventDate() async {
    final row =
        await (_db.select(_db.timeLines)
              ..orderBy([(t) => OrderingTerm.asc(t.eventDateTime)])
              ..limit(1))
            .getSingleOrNull();
    return row?.eventDateTime;
  }
}
