import 'dart:typed_data';

import 'package:simplelog/data/database/app_database.dart';
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
import 'package:simplelog/domain/repositories/logbook_repository_contract.dart';
import 'package:simplelog/domain/validation/flight_write_validator.dart';
import 'package:simplelog/domain/validation/validation_issue.dart';

/// Application-layer facade that orchestrates logbook operations.
///
/// It validates write inputs and delegates persistence/query work to
/// [LogbookRepositoryContract].
class LogbookUseCases {
  /// Creates use cases wired to [_repository].
  ///
  /// [flightWriteValidator] can be overridden in tests.
  LogbookUseCases(
    this._repository, {
    FlightWriteValidator flightWriteValidator = const FlightWriteValidator(),
  }) : _flightWriteValidator = flightWriteValidator;

  final LogbookRepositoryContract _repository;

  /// Validator used before creating/updating flights.
  final FlightWriteValidator _flightWriteValidator;

  /// Watches logbook entries that match [filters].
  Stream<List<LogbookEntry>> watchLogbook(LogbookFilters filters) {
    return _repository.watchLogbook(filters);
  }

  /// Fetches one paginated logbook slice for [filters].
  Future<List<LogbookEntry>> fetchLogbookPage(
    LogbookFilters filters, {
    required int limit,
    required int offset,
    Set<int>? includedFlightIds,
  }) {
    return _repository.fetchLogbookPage(
      filters,
      limit: limit,
      offset: offset,
      includedFlightIds: includedFlightIds,
    );
  }

  /// Returns earliest timeline date among stored entries, if any.
  Future<DateTime?> fetchFirstEventDate() => _repository.fetchFirstEventDate();

  /// Returns the entry attached to [timeLineId], or `null` if missing.
  Future<LogbookEntry?> fetchEntryByTimelineId(int timeLineId) =>
      _repository.fetchEntryByTimelineId(timeLineId);

  /// Finds a flight by primary key.
  Future<Flight?> findFlightById(int flightId) =>
      _repository.findFlightById(flightId);

  /// Loads all data required to edit a flight.
  Future<FlightEditData?> loadFlightEditData(int flightId) =>
      _repository.loadFlightEditData(flightId);

  /// Returns flight crew assignments for [flightId].
  Future<List<FlightCrewAssignment>> fetchFlightCrewAssignments(int flightId) =>
      _repository.fetchFlightCrewAssignments(flightId);

  /// Toggles lock state for the provided logbook [entry].
  Future<void> toggleEntryLock(LogbookEntry entry) =>
      _repository.toggleEntryLock(entry);

  /// Toggles lock state for a duty period by id.
  Future<void> toggleDutyLock(int dutyId) => _repository.toggleDutyLock(dutyId);

  /// Finds a duty period by id.
  Future<DutyPeriod?> findDutyById(int dutyId) =>
      _repository.findDutyById(dutyId);

  /// Loads all data required to edit a duty period.
  Future<DutyEditData?> loadDutyEditData(int dutyId) =>
      _repository.loadDutyEditData(dutyId);

  /// Finds a positioning entry by id.
  Future<Positioning?> findPositioningById(int positioningId) =>
      _repository.findPositioningById(positioningId);

  /// Loads all data required to edit a positioning entry.
  Future<PositioningEditData?> loadPositioningEditData(int positioningId) =>
      _repository.loadPositioningEditData(positioningId);

  /// Finds a simulator session by id.
  Future<SimulatorTraining?> findSimulatorTrainingById(int simulatorId) =>
      _repository.findSimulatorTrainingById(simulatorId);

  /// Loads all data required to edit a simulator session.
  Future<SimulatorEditData?> loadSimulatorEditData(int simulatorId) =>
      _repository.loadSimulatorEditData(simulatorId);

  /// Returns simulator crew assignments for [simulatorId].
  Future<List<SimulatorCrewAssignment>> fetchSimulatorCrewAssignments(
    int simulatorId,
  ) => _repository.fetchSimulatorCrewAssignments(simulatorId);

  /// Creates a duty period using UTC [start]/[end] and computed minutes.
  Future<void> createDuty({
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  }) {
    return _repository.createDuty(
      start: start,
      end: end,
      dutyMinutes: dutyMinutes,
      factoredMinutes: factoredMinutes,
    );
  }

  /// Updates an existing [duty] period with new timing values.
  Future<void> updateDuty({
    required DutyPeriod duty,
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  }) {
    return _repository.updateDuty(
      duty: duty,
      start: start,
      end: end,
      dutyMinutes: dutyMinutes,
      factoredMinutes: factoredMinutes,
    );
  }

  /// Creates a positioning leg.
  Future<void> createPositioning({
    required int departureAirportId,
    required int arrivalAirportId,
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int totalMinutes,
    required String notes,
  }) {
    return _repository.createPositioning(
      departureAirportId: departureAirportId,
      arrivalAirportId: arrivalAirportId,
      departureDateTime: departureDateTime,
      arrivalDateTime: arrivalDateTime,
      totalMinutes: totalMinutes,
      notes: notes,
    );
  }

  /// Updates an existing [positioning] leg.
  Future<void> updatePositioning({
    required Positioning positioning,
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int departureAirportId,
    required int arrivalAirportId,
    required int totalMinutes,
    required String notes,
  }) {
    return _repository.updatePositioning(
      positioning: positioning,
      departureDateTime: departureDateTime,
      arrivalDateTime: arrivalDateTime,
      departureAirportId: departureAirportId,
      arrivalAirportId: arrivalAirportId,
      totalMinutes: totalMinutes,
      notes: notes,
    );
  }

  /// Validates [input] without writing data.
  ValidationReport validateFlightWrite(FlightWriteInput input) {
    return _flightWriteValidator.validate(input);
  }

  /// Creates a flight if [input] passes validation.
  ///
  /// Returns validation warnings and errors in [WriteResult].
  Future<WriteResult<void>> createFlight({
    required FlightWriteInput input,
  }) async {
    final validation = _flightWriteValidator.validate(input);
    if (validation.hasErrors) {
      return WriteResult.failure(errors: validation.errors);
    }
    await _repository.createFlight(input: input);
    return WriteResult.success(warnings: validation.warnings);
  }

  /// Updates [flight] if [input] passes validation.
  ///
  /// Returns validation warnings and errors in [WriteResult].
  Future<WriteResult<void>> updateFlight({
    required Flight flight,
    required FlightWriteInput input,
  }) async {
    final validation = _flightWriteValidator.validate(input);
    if (validation.hasErrors) {
      return WriteResult.failure(errors: validation.errors);
    }
    await _repository.updateFlight(flight: flight, input: input);
    return WriteResult.success(warnings: validation.warnings);
  }

  /// Creates a simulator training record and optional endorsement payload.
  Future<void> createSimulatorTraining({
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
    String? endorsementData,
    Uint8List? endorsementSignatureImage,
  }) {
    return _repository.createSimulatorTraining(
      aircraftId: aircraftId,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      totalMinutes: totalMinutes,
      remarks: remarks,
      notes: notes,
      crewAssignments: crewAssignments,
      endorsementData: endorsementData,
      endorsementSignatureImage: endorsementSignatureImage,
    );
  }

  /// Updates [simulatorTraining] and related crew/endorsement data.
  Future<void> updateSimulatorTraining({
    required SimulatorTraining simulatorTraining,
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
    String? endorsementData,
    Uint8List? endorsementSignatureImage,
  }) {
    return _repository.updateSimulatorTraining(
      simulatorTraining: simulatorTraining,
      aircraftId: aircraftId,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      totalMinutes: totalMinutes,
      remarks: remarks,
      notes: notes,
      crewAssignments: crewAssignments,
      endorsementData: endorsementData,
      endorsementSignatureImage: endorsementSignatureImage,
    );
  }

  /// Verifies stored endorsement hash integrity for flight [flightId].
  Future<bool> verifyFlightEndorsementHash(int flightId) =>
      _repository.verifyFlightEndorsementHash(flightId);

  /// Verifies stored endorsement hash integrity for simulator [simulatorId].
  Future<bool> verifySimulatorEndorsementHash(int simulatorId) =>
      _repository.verifySimulatorEndorsementHash(simulatorId);

  /// Returns formatted crew labels for one flight.
  Future<List<String>> fetchFlightCrewLabels(int flightId) =>
      _repository.fetchFlightCrewLabels(flightId);

  /// Returns detailed crew rows for one flight.
  Future<List<CrewInfoItem>> fetchFlightCrewInfo(int flightId) =>
      _repository.fetchFlightCrewInfo(flightId);

  /// Returns formatted crew labels for one simulator session.
  Future<List<String>> fetchSimulatorCrewLabels(int simulatorId) =>
      _repository.fetchSimulatorCrewLabels(simulatorId);

  /// Returns detailed crew rows for one simulator session.
  Future<List<CrewInfoItem>> fetchSimulatorCrewInfo(int simulatorId) =>
      _repository.fetchSimulatorCrewInfo(simulatorId);

  /// Fetches all entries associated with airport [airportId].
  Future<List<LogbookEntry>> fetchEntriesForAirport(int airportId) =>
      _repository.fetchEntriesForAirport(airportId);

  /// Fetches a page of entries associated with airport [airportId].
  Future<List<LogbookEntry>> fetchEntriesForAirportPage(
    int airportId, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForAirportPage(
    airportId,
    limit: limit,
    offset: offset,
  );

  /// Returns aggregated flight totals for airport [airportId].
  Future<LogbookFlightSummary> fetchFlightSummaryForAirport(int airportId) =>
      _repository.fetchFlightSummaryForAirport(airportId);

  /// Fetches all entries associated with aircraft [aircraftId].
  Future<List<LogbookEntry>> fetchEntriesForAircraft(int aircraftId) =>
      _repository.fetchEntriesForAircraft(aircraftId);

  /// Fetches a page of entries associated with aircraft [aircraftId].
  Future<List<LogbookEntry>> fetchEntriesForAircraftPage(
    int aircraftId, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForAircraftPage(
    aircraftId,
    limit: limit,
    offset: offset,
  );

  /// Returns aggregated flight totals for aircraft [aircraftId].
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraft(int aircraftId) =>
      _repository.fetchFlightSummaryForAircraft(aircraftId);

  /// Fetches all entries associated with aircraft type [aircraftTypeId].
  Future<List<LogbookEntry>> fetchEntriesForAircraftType(int aircraftTypeId) =>
      _repository.fetchEntriesForAircraftType(aircraftTypeId);

  /// Fetches a page of entries for aircraft type [aircraftTypeId].
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypePage(
    int aircraftTypeId, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForAircraftTypePage(
    aircraftTypeId,
    limit: limit,
    offset: offset,
  );

  /// Returns aggregated flight totals for aircraft type [aircraftTypeId].
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftType(
    int aircraftTypeId,
  ) => _repository.fetchFlightSummaryForAircraftType(aircraftTypeId);

  /// Fetches a paged entry list for a family represented by [aircraftTypeIds].
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypeFamilyPage(
    List<int> aircraftTypeIds, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForAircraftTypeFamilyPage(
    aircraftTypeIds,
    limit: limit,
    offset: offset,
  );

  /// Returns aggregated totals for a family represented by [aircraftTypeIds].
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftTypeFamily(
    List<int> aircraftTypeIds,
  ) => _repository.fetchFlightSummaryForAircraftTypeFamily(aircraftTypeIds);

  /// Fetches all entries associated with crew member [crewId].
  Future<List<LogbookEntry>> fetchEntriesForCrew(int crewId) =>
      _repository.fetchEntriesForCrew(crewId);

  /// Fetches a paged list of entries associated with crew member [crewId].
  Future<List<LogbookEntry>> fetchEntriesForCrewPage(
    int crewId, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForCrewPage(
    crewId,
    limit: limit,
    offset: offset,
  );

  /// Returns aggregated flight totals for crew member [crewId].
  Future<LogbookFlightSummary> fetchFlightSummaryForCrew(int crewId) =>
      _repository.fetchFlightSummaryForCrew(crewId);

  /// Deletes the concrete record represented by [entry].
  Future<void> deleteEntry(LogbookEntry entry) =>
      _repository.deleteEntry(entry);

  /// Deletes duty entry with id [dutyId].
  Future<void> deleteDutyById(int dutyId) => _repository.deleteDutyById(dutyId);
}
