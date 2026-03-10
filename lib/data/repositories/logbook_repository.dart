import 'dart:async';

import 'package:drift/drift.dart';
import 'package:simplelog/core/flight/pilot_function_logic.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/pilot_function.dart';
import 'package:simplelog/data/models/crew_info_item.dart';
import 'package:simplelog/data/models/duty_edit_data.dart';
import 'package:simplelog/data/models/flight_edit_data.dart';
import 'package:simplelog/data/models/flight_write_input.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/models/logbook_flight_summary.dart';
import 'package:simplelog/data/models/positioning_edit_data.dart';
import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';
import 'package:simplelog/data/models/simulator_edit_data.dart';
import 'package:simplelog/data/security/entry_endorsement_hash_service.dart';
import 'package:simplelog/domain/repositories/logbook_repository_contract.dart';

/// Drift-backed implementation of [LogbookRepositoryContract].
class LogbookRepository implements LogbookRepositoryContract {
  /// Creates the repository with the shared app database.
  LogbookRepository(this._db);

  final AppDatabase _db;
  final EntryEndorsementHashService _endorsementHashService =
      EntryEndorsementHashService();

  @override
  Future<void> toggleEntryLock(LogbookEntry entry) async {
    switch (entry.type) {
      case LogbookEventType.flight:
        final item = entry.flight;
        if (item == null) return;
        if (item.isLocked &&
            _hasEndorsement(item.endorsementData, item.signatureImage)) {
          await _db
              .update(_db.flights)
              .replace(
                item.copyWith(
                  isLocked: false,
                  signatureImage: const Value(null),
                  endorsementData: const Value(null),
                  endorsementHash: const Value(null),
                ),
              );
          return;
        }
        await _db
            .update(_db.flights)
            .replace(item.copyWith(isLocked: !item.isLocked));
        return;
      case LogbookEventType.simulatorTraining:
        final item = entry.simulatorTraining;
        if (item == null) return;
        if (item.isLocked &&
            _hasEndorsement(item.endorsementData, item.signatureImage)) {
          await _db
              .update(_db.simulatorTrainings)
              .replace(
                item.copyWith(
                  isLocked: false,
                  signatureImage: const Value(null),
                  endorsementData: const Value(null),
                  endorsementHash: const Value(null),
                ),
              );
          return;
        }
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

  @override
  Future<void> toggleDutyLock(int dutyId) async {
    final duty = await findDutyById(dutyId);
    if (duty == null) return;
    await _db
        .update(_db.dutyPeriods)
        .replace(duty.copyWith(isLocked: !duty.isLocked));
  }

  @override
  Future<DutyPeriod?> findDutyById(int dutyId) async {
    return (_db.select(
      _db.dutyPeriods,
    )..where((t) => t.id.equals(dutyId))).getSingleOrNull();
  }

  @override
  Future<Flight?> findFlightById(int flightId) async {
    return (_db.select(
      _db.flights,
    )..where((t) => t.id.equals(flightId))).getSingleOrNull();
  }

  @override
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

  @override
  Future<List<FlightCrewAssignment>> fetchFlightCrewAssignments(int flightId) {
    return (_db.select(
      _db.flightCrewAssignments,
    )..where((t) => t.flightId.equals(flightId))).get();
  }

  @override
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

  @override
  Future<Positioning?> findPositioningById(int positioningId) async {
    return (_db.select(
      _db.positionings,
    )..where((t) => t.id.equals(positioningId))).getSingleOrNull();
  }

  @override
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

  @override
  Future<SimulatorTraining?> findSimulatorTrainingById(int simulatorId) async {
    return (_db.select(
      _db.simulatorTrainings,
    )..where((t) => t.id.equals(simulatorId))).getSingleOrNull();
  }

  @override
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

  @override
  Future<List<SimulatorCrewAssignment>> fetchSimulatorCrewAssignments(
    int simulatorId,
  ) {
    return (_db.select(
      _db.simulatorCrewAssignments,
    )..where((t) => t.simulatorId.equals(simulatorId))).get();
  }

  @override
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

  @override
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

  @override
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

  @override
  Future<void> createFlight({
    required FlightWriteInput input,
  }) async {
    await _db.transaction(() async {
      final cleanedEndorsementData = _normalizeEndorsementData(
        input.endorsementData,
      );
      final hasEndorsement = _hasEndorsement(
        cleanedEndorsementData,
        input.endorsementSignatureImage,
      );
      final departureTimelineId = await _db
          .into(_db.timeLines)
          .insert(
            TimeLinesCompanion.insert(eventDateTime: input.departureDateTime),
          );
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
              timeSimulatedInstrumentMinutes:
                  input.timeSimulatedInstrumentMinutes,
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
              pilotFunction: Value(
                PilotFunctionLogic.parse(input.pilotFunction),
              ),
              approachType: input.approachType,
              remarks: input.remarks,
              notes: input.notes,
              timeTotalBlockMinutes: Value(input.timeTotalBlockMinutes),
              isLocked: false,
              signatureImage: Value(input.endorsementSignatureImage),
              endorsementData: Value(cleanedEndorsementData),
              endorsementHash: const Value(null),
            ),
          );
      await _replaceFlightCrewAssignments(flightId, input.crewAssignments);
      await _recomputeAndPersistFlightEndorsementHash(
        flightId,
        isLocked: hasEndorsement,
      );
    });
  }

  @override
  Future<void> updateFlight({
    required Flight flight,
    required FlightWriteInput input,
  }) async {
    await _db.transaction(() async {
      final cleanedEndorsementData = _normalizeEndorsementData(
        input.endorsementData,
      );
      final hasEndorsement = _hasEndorsement(
        cleanedEndorsementData,
        input.endorsementSignatureImage,
      );
      final departureLine = await (_db.select(
        _db.timeLines,
      )..where((t) => t.id.equals(flight.departureDateTimeId))).getSingle();
      await _db
          .update(_db.timeLines)
          .replace(
            departureLine.copyWith(eventDateTime: input.departureDateTime),
          );
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
              timeSimulatedInstrumentMinutes:
                  input.timeSimulatedInstrumentMinutes,
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
              pilotFunction: PilotFunctionLogic.parse(input.pilotFunction),
              approachType: input.approachType,
              remarks: input.remarks,
              notes: input.notes,
              timeTotalBlockMinutes: input.timeTotalBlockMinutes,
              isLocked: flight.isLocked,
              signatureImage: Value(input.endorsementSignatureImage),
              endorsementData: Value(cleanedEndorsementData),
              endorsementHash: const Value(null),
            ),
          );
      await _replaceFlightCrewAssignments(flight.id, input.crewAssignments);
      await _recomputeAndPersistFlightEndorsementHash(
        flight.id,
        isLocked: hasEndorsement || flight.isLocked,
      );
    });
  }

  @override
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

  @override
  Future<void> createSimulatorTraining({
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
    Uint8List? endorsementSignatureImage,
    String? endorsementData,
  }) async {
    await _db.transaction(() async {
      final cleanedEndorsementData = _normalizeEndorsementData(endorsementData);
      final hasEndorsement = _hasEndorsement(
        cleanedEndorsementData,
        endorsementSignatureImage,
      );
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
              signatureImage: Value(endorsementSignatureImage),
              endorsementData: Value(cleanedEndorsementData),
              endorsementHash: const Value(null),
            ),
          );
      await _replaceSimulatorCrewAssignments(simulatorId, crewAssignments);
      await _recomputeAndPersistSimulatorEndorsementHash(
        simulatorId,
        isLocked: hasEndorsement,
      );
    });
  }

  @override
  Future<void> updateSimulatorTraining({
    required SimulatorTraining simulatorTraining,
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
    Uint8List? endorsementSignatureImage,
    String? endorsementData,
  }) async {
    await _db.transaction(() async {
      final cleanedEndorsementData = _normalizeEndorsementData(endorsementData);
      final hasEndorsement = _hasEndorsement(
        cleanedEndorsementData,
        endorsementSignatureImage,
      );
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
              isLocked: simulatorTraining.isLocked,
              signatureImage: Value(endorsementSignatureImage),
              endorsementData: Value(cleanedEndorsementData),
              endorsementHash: const Value(null),
            ),
          );
      await _replaceSimulatorCrewAssignments(
        simulatorTraining.id,
        crewAssignments,
      );
      await _recomputeAndPersistSimulatorEndorsementHash(
        simulatorTraining.id,
        isLocked: hasEndorsement || simulatorTraining.isLocked,
      );
    });
  }

  @override
  Future<bool> verifyFlightEndorsementHash(int flightId) async {
    final flight = await findFlightById(flightId);
    if (flight == null) return false;
    final stored = flight.endorsementHash?.trim();
    if (stored == null || stored.isEmpty) return true;
    for (final lockValue in {flight.isLocked, !flight.isLocked}) {
      for (final pilotFunctionValue in _flightPilotFunctionHashValues(flight)) {
        final expected = await _buildFlightEndorsementHash(
          flight,
          pilotFunctionValue: pilotFunctionValue,
          isLockedValue: lockValue,
        );
        if (expected == stored) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Future<bool> verifySimulatorEndorsementHash(int simulatorId) async {
    final simulatorTraining = await findSimulatorTrainingById(simulatorId);
    if (simulatorTraining == null) return false;
    final stored = simulatorTraining.endorsementHash?.trim();
    if (stored == null || stored.isEmpty) return true;
    for (final lockValue in {
      simulatorTraining.isLocked,
      !simulatorTraining.isLocked,
    }) {
      final expected = await _buildSimulatorEndorsementHash(
        simulatorTraining,
        isLockedValue: lockValue,
      );
      if (expected == stored) {
        return true;
      }
    }
    return false;
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

  @override
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

  @override
  Future<List<CrewInfoItem>> fetchFlightCrewInfo(int flightId) async {
    final rows = await (_db.select(_db.flightCrewAssignments).join([
      innerJoin(
        _db.crew,
        _db.crew.id.equalsExp(_db.flightCrewAssignments.crewId),
      ),
    ])..where(_db.flightCrewAssignments.flightId.equals(flightId))).get();
    return rows.map((row) {
      final crew = row.readTable(_db.crew);
      final assignment = row.readTable(_db.flightCrewAssignments);
      return CrewInfoItem(
        crewId: crew.id,
        name: crew.name,
        position: assignment.position,
        phone: crew.phone,
        email: crew.email,
        notes: crew.notes,
        picture: crew.picture,
      );
    }).toList();
  }

  @override
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

  @override
  Future<List<CrewInfoItem>> fetchSimulatorCrewInfo(int simulatorId) async {
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
      return CrewInfoItem(
        crewId: crew.id,
        name: crew.name,
        position: assignment.position,
        phone: crew.phone,
        email: crew.email,
        notes: crew.notes,
        picture: crew.picture,
      );
    }).toList();
  }

  @override
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

  @override
  Future<List<LogbookEntry>> fetchEntriesForAirportPage(
    int airportId, {
    required int limit,
    required int offset,
  }) async {
    if (limit <= 0) return const <LogbookEntry>[];
    final rows = await _db
        .customSelect(
          '''
SELECT timeline_id
FROM (
  SELECT tl.id AS timeline_id, tl.event_date_time AS event_ts
  FROM flights f
  INNER JOIN time_lines tl ON tl.id = f.departure_date_time_id
  WHERE f.departure_airport_id = ? OR f.arrival_airport_id = ?
  UNION ALL
  SELECT tl.id AS timeline_id, tl.event_date_time AS event_ts
  FROM positionings p
  INNER JOIN time_lines tl ON tl.id = p.departure_date_time_id
  WHERE p.departure_place_id = ? OR p.arrival_place_id = ?
)
ORDER BY event_ts DESC, timeline_id DESC
LIMIT ? OFFSET ?
''',
          variables: [
            Variable<int>(airportId),
            Variable<int>(airportId),
            Variable<int>(airportId),
            Variable<int>(airportId),
            Variable<int>(limit),
            Variable<int>(offset),
          ],
          readsFrom: {_db.flights, _db.positionings, _db.timeLines},
        )
        .get();

    if (rows.isEmpty) return const <LogbookEntry>[];
    final timelineIds = rows
        .map((row) => row.read<int>('timeline_id'))
        .where((id) => id > 0)
        .toList(growable: false);
    if (timelineIds.isEmpty) return const <LogbookEntry>[];

    return _fetchEntriesByTimelineIds(timelineIds);
  }

  @override
  Future<LogbookFlightSummary> fetchFlightSummaryForAirport(int airportId) {
    return _fetchFlightSummary(
      where:
          _db.flights.departureAirportId.equals(airportId) |
          _db.flights.arrivalAirportId.equals(airportId),
    );
  }

  @override
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

  @override
  Future<List<LogbookEntry>> fetchEntriesForAircraftPage(
    int aircraftId, {
    required int limit,
    required int offset,
  }) async {
    if (limit <= 0) return const <LogbookEntry>[];
    final rows = await _db
        .customSelect(
          '''
SELECT timeline_id
FROM (
  SELECT tl.id AS timeline_id, tl.event_date_time AS event_ts
  FROM flights f
  INNER JOIN time_lines tl ON tl.id = f.departure_date_time_id
  WHERE f.aircraft_id = ?
  UNION ALL
  SELECT tl.id AS timeline_id, tl.event_date_time AS event_ts
  FROM simulator_trainings st
  INNER JOIN time_lines tl ON tl.id = st.start_time_line_id
  WHERE st.aircraft_id = ?
)
ORDER BY event_ts DESC, timeline_id DESC
LIMIT ? OFFSET ?
''',
          variables: [
            Variable<int>(aircraftId),
            Variable<int>(aircraftId),
            Variable<int>(limit),
            Variable<int>(offset),
          ],
          readsFrom: {_db.flights, _db.simulatorTrainings, _db.timeLines},
        )
        .get();

    if (rows.isEmpty) return const <LogbookEntry>[];
    final timelineIds = rows
        .map((row) => row.read<int>('timeline_id'))
        .where((id) => id > 0)
        .toList(growable: false);
    if (timelineIds.isEmpty) return const <LogbookEntry>[];

    return _fetchEntriesByTimelineIds(timelineIds);
  }

  @override
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraft(int aircraftId) {
    return _fetchFlightSummary(
      where: _db.flights.aircraftId.equals(aircraftId),
    );
  }

  @override
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

  @override
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypePage(
    int aircraftTypeId, {
    required int limit,
    required int offset,
  }) async {
    if (limit <= 0) return const <LogbookEntry>[];
    final rows = await _db
        .customSelect(
          '''
SELECT timeline_id
FROM (
  SELECT tl.id AS timeline_id, tl.event_date_time AS event_ts
  FROM flights f
  INNER JOIN aircrafts a ON a.id = f.aircraft_id
  INNER JOIN time_lines tl ON tl.id = f.departure_date_time_id
  WHERE a.aircraft_type_id = ?
  UNION ALL
  SELECT tl.id AS timeline_id, tl.event_date_time AS event_ts
  FROM simulator_trainings st
  INNER JOIN aircrafts a ON a.id = st.aircraft_id
  INNER JOIN time_lines tl ON tl.id = st.start_time_line_id
  WHERE a.aircraft_type_id = ?
)
ORDER BY event_ts DESC, timeline_id DESC
LIMIT ? OFFSET ?
''',
          variables: [
            Variable<int>(aircraftTypeId),
            Variable<int>(aircraftTypeId),
            Variable<int>(limit),
            Variable<int>(offset),
          ],
          readsFrom: {
            _db.flights,
            _db.simulatorTrainings,
            _db.aircrafts,
            _db.timeLines,
          },
        )
        .get();

    if (rows.isEmpty) return const <LogbookEntry>[];
    final timelineIds = rows
        .map((row) => row.read<int>('timeline_id'))
        .where((id) => id > 0)
        .toList(growable: false);
    if (timelineIds.isEmpty) return const <LogbookEntry>[];

    return _fetchEntriesByTimelineIds(timelineIds);
  }

  @override
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftType(
    int aircraftTypeId,
  ) {
    return _fetchFlightSummary(
      joinBuilder: (query) => query.join([
        innerJoin(
          _db.aircrafts,
          _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
        ),
      ]),
      where: _db.aircrafts.aircraftTypeId.equals(aircraftTypeId),
    );
  }

  @override
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypeFamilyPage(
    List<int> aircraftTypeIds, {
    required int limit,
    required int offset,
  }) async {
    final ids = aircraftTypeIds.where((id) => id > 0).toSet().toList();
    if (ids.isEmpty || limit <= 0) return const <LogbookEntry>[];
    final placeholders = List.filled(ids.length, '?').join(',');
    final variables = <Variable<Object>>[
      ...ids.map<Variable<Object>>(Variable<int>.new),
      ...ids.map<Variable<Object>>(Variable<int>.new),
      Variable<int>(limit),
      Variable<int>(offset),
    ];

    final rows = await _db
        .customSelect(
          '''
SELECT timeline_id
FROM (
  SELECT tl.id AS timeline_id, tl.event_date_time AS event_ts
  FROM flights f
  INNER JOIN aircrafts a ON a.id = f.aircraft_id
  INNER JOIN time_lines tl ON tl.id = f.departure_date_time_id
  WHERE a.aircraft_type_id IN ($placeholders)
  UNION ALL
  SELECT tl.id AS timeline_id, tl.event_date_time AS event_ts
  FROM simulator_trainings st
  INNER JOIN aircrafts a ON a.id = st.aircraft_id
  INNER JOIN time_lines tl ON tl.id = st.start_time_line_id
  WHERE a.aircraft_type_id IN ($placeholders)
)
ORDER BY event_ts DESC, timeline_id DESC
LIMIT ? OFFSET ?
''',
          variables: variables,
          readsFrom: {
            _db.flights,
            _db.simulatorTrainings,
            _db.aircrafts,
            _db.timeLines,
          },
        )
        .get();

    if (rows.isEmpty) return const <LogbookEntry>[];
    final timelineIds = rows
        .map((row) => row.read<int>('timeline_id'))
        .where((id) => id > 0)
        .toList(growable: false);
    if (timelineIds.isEmpty) return const <LogbookEntry>[];

    return _fetchEntriesByTimelineIds(timelineIds);
  }

  @override
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftTypeFamily(
    List<int> aircraftTypeIds,
  ) {
    final ids = aircraftTypeIds.where((id) => id > 0).toSet().toList();
    if (ids.isEmpty) return Future.value(const LogbookFlightSummary.empty());
    return _fetchFlightSummary(
      joinBuilder: (query) => query.join([
        innerJoin(
          _db.aircrafts,
          _db.aircrafts.id.equalsExp(_db.flights.aircraftId),
        ),
      ]),
      where: _db.aircrafts.aircraftTypeId.isIn(ids),
    );
  }

  @override
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

  @override
  Future<List<LogbookEntry>> fetchEntriesForCrewPage(
    int crewId, {
    required int limit,
    required int offset,
  }) async {
    if (limit <= 0) return const <LogbookEntry>[];
    final rows = await _db
        .customSelect(
          '''
SELECT timeline_id
FROM (
  SELECT tl.id AS timeline_id, tl.event_date_time AS event_ts
  FROM flights f
  INNER JOIN flight_crew_assignments fca ON fca.flight_id = f.id
  INNER JOIN time_lines tl ON tl.id = f.departure_date_time_id
  WHERE fca.crew_id = ?
  UNION ALL
  SELECT tl.id AS timeline_id, tl.event_date_time AS event_ts
  FROM simulator_trainings st
  INNER JOIN simulator_crew_assignments sca ON sca.simulator_id = st.id
  INNER JOIN time_lines tl ON tl.id = st.start_time_line_id
  WHERE sca.crew_id = ?
)
ORDER BY event_ts DESC, timeline_id DESC
LIMIT ? OFFSET ?
''',
          variables: [
            Variable<int>(crewId),
            Variable<int>(crewId),
            Variable<int>(limit),
            Variable<int>(offset),
          ],
          readsFrom: {
            _db.flights,
            _db.flightCrewAssignments,
            _db.simulatorTrainings,
            _db.simulatorCrewAssignments,
            _db.timeLines,
          },
        )
        .get();

    if (rows.isEmpty) return const <LogbookEntry>[];
    final timelineIds = rows
        .map((row) => row.read<int>('timeline_id'))
        .where((id) => id > 0)
        .toList(growable: false);
    if (timelineIds.isEmpty) return const <LogbookEntry>[];

    return _fetchEntriesByTimelineIds(timelineIds);
  }

  @override
  Future<LogbookFlightSummary> fetchFlightSummaryForCrew(int crewId) {
    return _fetchFlightSummary(
      joinBuilder: (query) => query.join([
        innerJoin(
          _db.flightCrewAssignments,
          _db.flightCrewAssignments.flightId.equalsExp(_db.flights.id),
        ),
      ]),
      where: _db.flightCrewAssignments.crewId.equals(crewId),
    );
  }

  @override
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

  @override
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

  @override
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

  @override
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

  @override
  Future<List<LogbookEntry>> fetchLogbookPage(
    LogbookFilters filters, {
    required int limit,
    required int offset,
    Set<int>? includedFlightIds,
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
      includedFlightIds: includedFlightIds,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      positioningDeparture: positioningDeparture,
      positioningArrival: positioningArrival,
      dutyStart: dutyStart,
      dutyEnd: dutyEnd,
      simAircraft: simAircraft,
      simAircraftType: simAircraftType,
    )..limit(limit, offset: offset);

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

  JoinedSelectStatement<HasResultSet, dynamic> _buildBaseQuery({
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

  JoinedSelectStatement<HasResultSet, dynamic> _buildQuery(
    LogbookFilters filters, {
    required $AirportsTable departureAirport,
    required $AirportsTable arrivalAirport,
    required $AirportsTable positioningDeparture,
    required $AirportsTable positioningArrival,
    required $DutyPeriodsTable dutyStart,
    required $DutyPeriodsTable dutyEnd,
    required $AircraftsTable simAircraft,
    required $AircraftTypesTable simAircraftType,
    Set<int>? includedFlightIds,
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
    if (includedFlightIds != null && includedFlightIds.isNotEmpty) {
      query.where(
        _db.flights.id.isNull() | _db.flights.id.isIn(includedFlightIds),
      );
    }

    return query..orderBy([
      OrderingTerm.desc(_db.timeLines.eventDateTime),
      OrderingTerm.desc(_db.timeLines.id),
    ]);
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

  Future<List<LogbookEntry>> _fetchEntriesByTimelineIds(
    List<int> timelineIds,
  ) async {
    if (timelineIds.isEmpty) return const <LogbookEntry>[];

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
    )..where(_db.timeLines.id.isIn(timelineIds));

    final rows = await query.get();
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

    final orderIndex = <int, int>{
      for (var i = 0; i < timelineIds.length; i++) timelineIds[i]: i,
    };
    mapped.sort((a, b) {
      final ai = orderIndex[a.timeLine.id] ?? 1 << 30;
      final bi = orderIndex[b.timeLine.id] ?? 1 << 30;
      return ai.compareTo(bi);
    });
    return mapped;
  }

  Future<LogbookFlightSummary> _fetchFlightSummary({
    required Expression<bool> where,
    void Function(JoinedSelectStatement<$FlightsTable, Flight>)? joinBuilder,
  }) async {
    final totalBlockExpr = _db.flights.timeBlockMinutes.sum();
    final totalPicExpr = _db.flights.timePICMinutes.sum();
    final firstFlightExpr = _db.timeLines.eventDateTime.min();
    final lastFlightExpr = _db.timeLines.eventDateTime.max();

    final query = _db.selectOnly(_db.flights)
      ..addColumns([
        totalBlockExpr,
        totalPicExpr,
        firstFlightExpr,
        lastFlightExpr,
      ])
      ..join([
        innerJoin(
          _db.timeLines,
          _db.timeLines.id.equalsExp(_db.flights.departureDateTimeId),
        ),
      ]);
    joinBuilder?.call(query);
    query.where(where);

    final row = await query.getSingleOrNull();
    if (row == null) return const LogbookFlightSummary.empty();

    return LogbookFlightSummary(
      totalBlockMinutes: row.read(totalBlockExpr) ?? 0,
      totalPicMinutes: row.read(totalPicExpr) ?? 0,
      firstFlight: row.read(firstFlightExpr),
      lastFlight: row.read(lastFlightExpr),
    );
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

  String? _normalizeEndorsementData(String? value) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }
    return cleaned;
  }

  bool _hasEndorsement(String? endorsementData, Uint8List? signatureImage) {
    final hasData = endorsementData != null && endorsementData.isNotEmpty;
    final hasSignature = signatureImage != null && signatureImage.isNotEmpty;
    return hasData || hasSignature;
  }

  Future<void> _recomputeAndPersistFlightEndorsementHash(
    int flightId, {
    required bool isLocked,
  }) async {
    final flight = await findFlightById(flightId);
    if (flight == null) return;
    final hash = await _buildFlightEndorsementHash(
      flight,
      isLockedValue: isLocked,
    );
    await (_db.update(
      _db.flights,
    )..where((tbl) => tbl.id.equals(flight.id))).write(
      FlightsCompanion(
        endorsementHash: Value(hash),
        isLocked: Value(isLocked),
      ),
    );
  }

  Future<void> _recomputeAndPersistSimulatorEndorsementHash(
    int simulatorId, {
    required bool isLocked,
  }) async {
    final simulatorTraining = await findSimulatorTrainingById(simulatorId);
    if (simulatorTraining == null) return;
    final hash = await _buildSimulatorEndorsementHash(
      simulatorTraining,
      isLockedValue: isLocked,
    );
    await (_db.update(
      _db.simulatorTrainings,
    )..where((tbl) => tbl.id.equals(simulatorTraining.id))).write(
      SimulatorTrainingsCompanion(
        endorsementHash: Value(hash),
        isLocked: Value(isLocked),
      ),
    );
  }

  Iterable<String?> _flightPilotFunctionHashValues(Flight flight) sync* {
    final normalized = PilotFunctionLogic.fromEnum(flight.pilotFunction);
    yield normalized;
    switch (flight.pilotFunction) {
      case PilotFunction.irp3:
        yield 'IRP 3';
      case PilotFunction.irp4:
        yield 'IRP 4';
      case PilotFunction.pf:
      case PilotFunction.pnf:
      case PilotFunction.pfPnf:
      case PilotFunction.pnfPf:
      case PilotFunction.other:
        break;
    }
  }

  Future<String?> _buildFlightEndorsementHash(
    Flight flight, {
    String? pilotFunctionValue,
    bool? isLockedValue,
  }) async {
    if (!_hasEndorsement(flight.endorsementData, flight.signatureImage)) {
      return null;
    }
    final departureLine = await (_db.select(
      _db.timeLines,
    )..where((t) => t.id.equals(flight.departureDateTimeId))).getSingleOrNull();
    if (departureLine == null) {
      return null;
    }
    final assignments =
        await (_db.select(_db.flightCrewAssignments)
              ..where((t) => t.flightId.equals(flight.id))
              ..orderBy([
                (t) => OrderingTerm.asc(t.crewId),
                (t) => OrderingTerm.asc(t.position),
              ]))
            .get();
    return _endorsementHashService.hashFlight(
      flight: flight,
      departureDateTime: departureLine.eventDateTime,
      crewAssignments: assignments,
      pilotFunctionValue: pilotFunctionValue,
      isLockedValue: isLockedValue,
    );
  }

  Future<String?> _buildSimulatorEndorsementHash(
    SimulatorTraining simulatorTraining, {
    bool? isLockedValue,
  }) async {
    if (!_hasEndorsement(
      simulatorTraining.endorsementData,
      simulatorTraining.signatureImage,
    )) {
      return null;
    }
    final startLine =
        await (_db.select(
              _db.timeLines,
            )..where((t) => t.id.equals(simulatorTraining.startTimeLineId)))
            .getSingleOrNull();
    if (startLine == null) {
      return null;
    }
    final assignments =
        await (_db.select(_db.simulatorCrewAssignments)
              ..where((t) => t.simulatorId.equals(simulatorTraining.id))
              ..orderBy([
                (t) => OrderingTerm.asc(t.crewId),
                (t) => OrderingTerm.asc(t.position),
              ]))
            .get();
    return _endorsementHashService.hashSimulator(
      simulator: simulatorTraining,
      startDateTime: startLine.eventDateTime,
      crewAssignments: assignments,
      isLockedValue: isLockedValue,
    );
  }

  @override
  Future<DateTime?> fetchFirstEventDate() async {
    final row =
        await (_db.select(_db.timeLines)
              ..orderBy([(t) => OrderingTerm.asc(t.eventDateTime)])
              ..limit(1))
            .getSingleOrNull();
    return row?.eventDateTime;
  }
}
