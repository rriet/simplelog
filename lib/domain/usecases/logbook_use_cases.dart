import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_info_item.dart';
import 'package:simplelog/data/models/flight_edit_data.dart';
import 'package:simplelog/data/models/flight_write_input.dart';
import 'package:simplelog/data/models/duty_edit_data.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/models/positioning_edit_data.dart';
import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';
import 'package:simplelog/data/models/simulator_edit_data.dart';
import 'package:simplelog/domain/validation/flight_write_validator.dart';
import 'package:simplelog/domain/validation/validation_issue.dart';
import 'package:simplelog/domain/repositories/logbook_repository_contract.dart';

class LogbookUseCases {
  LogbookUseCases(
    this._repository, {
    FlightWriteValidator flightWriteValidator = const FlightWriteValidator(),
  }) : _flightWriteValidator = flightWriteValidator;

  final LogbookRepositoryContract _repository;
  final FlightWriteValidator _flightWriteValidator;

  Stream<List<LogbookEntry>> watchLogbook(LogbookFilters filters) {
    return _repository.watchLogbook(filters);
  }

  Future<List<LogbookEntry>> fetchLogbookPage(
    LogbookFilters filters, {
    required int limit,
    required int offset,
  }) {
    return _repository.fetchLogbookPage(filters, limit: limit, offset: offset);
  }

  Future<DateTime?> fetchFirstEventDate() => _repository.fetchFirstEventDate();
  Future<LogbookEntry?> fetchEntryByTimelineId(int timeLineId) =>
      _repository.fetchEntryByTimelineId(timeLineId);
  Future<Flight?> findFlightById(int flightId) =>
      _repository.findFlightById(flightId);
  Future<FlightEditData?> loadFlightEditData(int flightId) =>
      _repository.loadFlightEditData(flightId);
  Future<List<FlightCrewAssignment>> fetchFlightCrewAssignments(int flightId) =>
      _repository.fetchFlightCrewAssignments(flightId);

  Future<void> toggleEntryLock(LogbookEntry entry) =>
      _repository.toggleEntryLock(entry);
  Future<void> toggleDutyLock(int dutyId) => _repository.toggleDutyLock(dutyId);
  Future<DutyPeriod?> findDutyById(int dutyId) =>
      _repository.findDutyById(dutyId);
  Future<DutyEditData?> loadDutyEditData(int dutyId) =>
      _repository.loadDutyEditData(dutyId);
  Future<Positioning?> findPositioningById(int positioningId) =>
      _repository.findPositioningById(positioningId);
  Future<PositioningEditData?> loadPositioningEditData(int positioningId) =>
      _repository.loadPositioningEditData(positioningId);
  Future<SimulatorTraining?> findSimulatorTrainingById(int simulatorId) =>
      _repository.findSimulatorTrainingById(simulatorId);
  Future<SimulatorEditData?> loadSimulatorEditData(int simulatorId) =>
      _repository.loadSimulatorEditData(simulatorId);
  Future<List<SimulatorCrewAssignment>> fetchSimulatorCrewAssignments(
    int simulatorId,
  ) => _repository.fetchSimulatorCrewAssignments(simulatorId);

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

  ValidationReport validateFlightWrite(FlightWriteInput input) {
    return _flightWriteValidator.validate(input);
  }

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
      crewAssignments: crewAssignments,
    );
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
    );
  }

  Future<List<String>> fetchFlightCrewLabels(int flightId) =>
      _repository.fetchFlightCrewLabels(flightId);
  Future<List<CrewInfoItem>> fetchFlightCrewInfo(int flightId) =>
      _repository.fetchFlightCrewInfo(flightId);
  Future<List<String>> fetchSimulatorCrewLabels(int simulatorId) =>
      _repository.fetchSimulatorCrewLabels(simulatorId);
  Future<List<CrewInfoItem>> fetchSimulatorCrewInfo(int simulatorId) =>
      _repository.fetchSimulatorCrewInfo(simulatorId);
  Future<List<LogbookEntry>> fetchEntriesForAirport(int airportId) =>
      _repository.fetchEntriesForAirport(airportId);
  Future<List<LogbookEntry>> fetchEntriesForAircraft(int aircraftId) =>
      _repository.fetchEntriesForAircraft(aircraftId);
  Future<List<LogbookEntry>> fetchEntriesForAircraftType(int aircraftTypeId) =>
      _repository.fetchEntriesForAircraftType(aircraftTypeId);
  Future<List<LogbookEntry>> fetchEntriesForCrew(int crewId) =>
      _repository.fetchEntriesForCrew(crewId);

  Future<void> deleteEntry(LogbookEntry entry) =>
      _repository.deleteEntry(entry);
  Future<void> deleteDutyById(int dutyId) => _repository.deleteDutyById(dutyId);
}
