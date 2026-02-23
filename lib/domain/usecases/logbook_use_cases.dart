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

/// Public API documentation.
class LogbookUseCases {
  /// Public API documentation.
  LogbookUseCases(
    this._repository, {
    FlightWriteValidator flightWriteValidator = const FlightWriteValidator(),
  }) : _flightWriteValidator = flightWriteValidator;

  final LogbookRepositoryContract _repository;
  /// Public API documentation.
  final FlightWriteValidator _flightWriteValidator;

  /// Public API documentation.
  Stream<List<LogbookEntry>> watchLogbook(LogbookFilters filters) {
    /// Public API documentation.
    return _repository.watchLogbook(filters);
  }

  /// Public API documentation.
  Future<List<LogbookEntry>> fetchLogbookPage(
    LogbookFilters filters, {
    required int limit,
    required int offset,
  /// Public API documentation.
  }) {
    /// Public API documentation.
    return _repository.fetchLogbookPage(filters, limit: limit, offset: offset);
  }
/// Public API documentation.

  /// Public API documentation.
  Future<DateTime?> fetchFirstEventDate() => _repository.fetchFirstEventDate();
  /// Public API documentation.
  Future<LogbookEntry?> fetchEntryByTimelineId(int timeLineId) =>
      _repository.fetchEntryByTimelineId(timeLineId);
  /// Public API documentation.
  Future<Flight?> findFlightById(int flightId) =>
      _repository.findFlightById(flightId);
  /// Public API documentation.
  Future<FlightEditData?> loadFlightEditData(int flightId) =>
      _repository.loadFlightEditData(flightId);
  /// Public API documentation.
  Future<List<FlightCrewAssignment>> fetchFlightCrewAssignments(int flightId) =>
      /// Public API documentation.
      _repository.fetchFlightCrewAssignments(flightId);

  /// Public API documentation.
  Future<void> toggleEntryLock(LogbookEntry entry) =>
      /// Public API documentation.
      _repository.toggleEntryLock(entry);
  /// Public API documentation.
  Future<void> toggleDutyLock(int dutyId) => _repository.toggleDutyLock(dutyId);
  /// Public API documentation.
  Future<DutyPeriod?> findDutyById(int dutyId) =>
      _repository.findDutyById(dutyId);
  /// Public API documentation.
  Future<DutyEditData?> loadDutyEditData(int dutyId) =>
      /// Public API documentation.
      _repository.loadDutyEditData(dutyId);
  /// Public API documentation.
  Future<Positioning?> findPositioningById(int positioningId) =>
      _repository.findPositioningById(positioningId);
  /// Public API documentation.
  Future<PositioningEditData?> loadPositioningEditData(int positioningId) =>
      _repository.loadPositioningEditData(positioningId);
  /// Public API documentation.
  Future<SimulatorTraining?> findSimulatorTrainingById(int simulatorId) =>
      _repository.findSimulatorTrainingById(simulatorId);
  /// Public API documentation.
  Future<SimulatorEditData?> loadSimulatorEditData(int simulatorId) =>
      _repository.loadSimulatorEditData(simulatorId);
  /// Public API documentation.
  Future<List<SimulatorCrewAssignment>> fetchSimulatorCrewAssignments(
    int simulatorId,
  ) => _repository.fetchSimulatorCrewAssignments(simulatorId);

  /// Public API documentation.
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
    /// Public API documentation.
    );
  }

  /// Public API documentation.
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
  /// Public API documentation.
  }

  /// Public API documentation.
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
/// Public API documentation.

  /// Public API documentation.
  Future<void> updatePositioning({
    required Positioning positioning,
    /// Public API documentation.
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
      /// Public API documentation.
      departureAirportId: departureAirportId,
      arrivalAirportId: arrivalAirportId,
      totalMinutes: totalMinutes,
      notes: notes,
    );
  }

  /// Public API documentation.
  ValidationReport validateFlightWrite(FlightWriteInput input) {
    return _flightWriteValidator.validate(input);
  }

  /// Public API documentation.
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

  /// Public API documentation.
  Future<WriteResult<void>> updateFlight({
    required Flight flight,
    required FlightWriteInput input,
  }) async {
    final validation = _flightWriteValidator.validate(input);
    if (validation.hasErrors) {
      return WriteResult.failure(errors: validation.errors);
    /// Public API documentation.
    }
    await _repository.updateFlight(flight: flight, input: input);
    return WriteResult.success(warnings: validation.warnings);
  }

  /// Public API documentation.
  Future<void> createSimulatorTraining({
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
  }) {
    return _repository.createSimulatorTraining(
      aircraftId: aircraftId,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      totalMinutes: totalMinutes,
      remarks: remarks,
      notes: notes,
      /// Public API documentation.
      crewAssignments: crewAssignments,
    );
  /// Public API documentation.
  }

  /// Public API documentation.
  Future<void> updateSimulatorTraining({
    /// Public API documentation.
    required SimulatorTraining simulatorTraining,
    required int aircraftId,
    /// Public API documentation.
    required DateTime startDateTime,
    required DateTime? endDateTime,
    /// Public API documentation.
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
  }) {
    return _repository.updateSimulatorTraining(
      simulatorTraining: simulatorTraining,
      aircraftId: aircraftId,
      startDateTime: startDateTime,
      /// Public API documentation.
      endDateTime: endDateTime,
      totalMinutes: totalMinutes,
      /// Public API documentation.
      remarks: remarks,
      notes: notes,
      /// Public API documentation.
      crewAssignments: crewAssignments,
    );
  }

  /// Public API documentation.
  Future<List<String>> fetchFlightCrewLabels(int flightId) =>
      _repository.fetchFlightCrewLabels(flightId);
  /// Public API documentation.
  Future<List<CrewInfoItem>> fetchFlightCrewInfo(int flightId) =>
      /// Public API documentation.
      _repository.fetchFlightCrewInfo(flightId);
  /// Public API documentation.
  Future<List<String>> fetchSimulatorCrewLabels(int simulatorId) =>
      _repository.fetchSimulatorCrewLabels(simulatorId);
  /// Public API documentation.
  Future<List<CrewInfoItem>> fetchSimulatorCrewInfo(int simulatorId) =>
      _repository.fetchSimulatorCrewInfo(simulatorId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAirport(int airportId) =>
      _repository.fetchEntriesForAirport(airportId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAirportPage(
    int airportId, {
    /// Public API documentation.
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForAirportPage(
    /// Public API documentation.
    airportId,
    limit: limit,
    offset: offset,
  );
  /// Public API documentation.
  Future<LogbookFlightSummary> fetchFlightSummaryForAirport(int airportId) =>
      _repository.fetchFlightSummaryForAirport(airportId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAircraft(int aircraftId) =>
      /// Public API documentation.
      _repository.fetchEntriesForAircraft(aircraftId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAircraftPage(
    /// Public API documentation.
    int aircraftId, {
    required int limit,
    /// Public API documentation.
    required int offset,
  }) => _repository.fetchEntriesForAircraftPage(
    aircraftId,
    limit: limit,
    offset: offset,
  );
  /// Public API documentation.
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraft(int aircraftId) =>
      _repository.fetchFlightSummaryForAircraft(aircraftId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAircraftType(int aircraftTypeId) =>
      _repository.fetchEntriesForAircraftType(aircraftTypeId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypePage(
    /// Public API documentation.
    int aircraftTypeId, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForAircraftTypePage(
    aircraftTypeId,
    limit: limit,
    offset: offset,
  );
  /// Public API documentation.
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftType(
    int aircraftTypeId,
  ) => _repository.fetchFlightSummaryForAircraftType(aircraftTypeId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypeFamilyPage(
    List<int> aircraftTypeIds, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForAircraftTypeFamilyPage(
    aircraftTypeIds,
    limit: limit,
    offset: offset,
  );
  /// Public API documentation.
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftTypeFamily(
    List<int> aircraftTypeIds,
  ) => _repository.fetchFlightSummaryForAircraftTypeFamily(aircraftTypeIds);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForCrew(int crewId) =>
      _repository.fetchEntriesForCrew(crewId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForCrewPage(
    int crewId, {
    required int limit,
    required int offset,
  }) => _repository.fetchEntriesForCrewPage(
    crewId,
    limit: limit,
    offset: offset,
  );
  /// Public API documentation.
  Future<LogbookFlightSummary> fetchFlightSummaryForCrew(int crewId) =>
      _repository.fetchFlightSummaryForCrew(crewId);

  /// Public API documentation.
  Future<void> deleteEntry(LogbookEntry entry) =>
      _repository.deleteEntry(entry);
  /// Public API documentation.
  Future<void> deleteDutyById(int dutyId) => _repository.deleteDutyById(dutyId);
}
