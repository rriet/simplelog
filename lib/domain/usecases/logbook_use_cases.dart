import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/flight_edit_data.dart';
import 'package:simplelog/data/models/duty_edit_data.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/models/positioning_edit_data.dart';
import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';
import 'package:simplelog/data/models/simulator_edit_data.dart';
import 'package:simplelog/domain/repositories/logbook_repository_contract.dart';

class LogbookUseCases {
  LogbookUseCases(this._repository);

  final LogbookRepositoryContract _repository;

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

  Future<void> createFlight({
    required int aircraftId,
    required int departureAirportId,
    required int arrivalAirportId,
    required DateTime departureDateTime,
    required DateTime? takeOffDateTime,
    required DateTime? landingDateTime,
    required DateTime? arrivalDateTime,
    required String pilotFunction,
    required int ifrApproaches,
    required String approachType,
    required int takeOffsDays,
    required int takeOffsNight,
    required int landingsDay,
    required int landingsNight,
    required int timeBlockMinutes,
    required int timeTotalBlockMinutes,
    required int timeFlightMinutes,
    required int timePICMinutes,
    required int timePICUSMinutes,
    required int timeSICMinutes,
    required int timeDualMinutes,
    required int timeInstructorMinutes,
    required int timeIFRMinutes,
    required int timeInstrumentMinutes,
    required int timeSimulatedInstrumentMinutes,
    required int timeNightMinutes,
    required int timeCrossCountryMinutes,
    required int timeCustom1Minutes,
    required int timeCustom2Minutes,
    required int timeCustom3Minutes,
    required int timeCustom4Minutes,
    required int distanceNM,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
  }) {
    return _repository.createFlight(
      aircraftId: aircraftId,
      departureAirportId: departureAirportId,
      arrivalAirportId: arrivalAirportId,
      departureDateTime: departureDateTime,
      takeOffDateTime: takeOffDateTime,
      landingDateTime: landingDateTime,
      arrivalDateTime: arrivalDateTime,
      pilotFunction: pilotFunction,
      ifrApproaches: ifrApproaches,
      approachType: approachType,
      takeOffsDays: takeOffsDays,
      takeOffsNight: takeOffsNight,
      landingsDay: landingsDay,
      landingsNight: landingsNight,
      timeBlockMinutes: timeBlockMinutes,
      timeTotalBlockMinutes: timeTotalBlockMinutes,
      timeFlightMinutes: timeFlightMinutes,
      timePICMinutes: timePICMinutes,
      timePICUSMinutes: timePICUSMinutes,
      timeSICMinutes: timeSICMinutes,
      timeDualMinutes: timeDualMinutes,
      timeInstructorMinutes: timeInstructorMinutes,
      timeIFRMinutes: timeIFRMinutes,
      timeInstrumentMinutes: timeInstrumentMinutes,
      timeSimulatedInstrumentMinutes: timeSimulatedInstrumentMinutes,
      timeNightMinutes: timeNightMinutes,
      timeCrossCountryMinutes: timeCrossCountryMinutes,
      timeCustom1Minutes: timeCustom1Minutes,
      timeCustom2Minutes: timeCustom2Minutes,
      timeCustom3Minutes: timeCustom3Minutes,
      timeCustom4Minutes: timeCustom4Minutes,
      distanceNM: distanceNM,
      remarks: remarks,
      notes: notes,
      crewAssignments: crewAssignments,
    );
  }

  Future<void> updateFlight({
    required Flight flight,
    required int aircraftId,
    required int departureAirportId,
    required int arrivalAirportId,
    required DateTime departureDateTime,
    required DateTime? takeOffDateTime,
    required DateTime? landingDateTime,
    required DateTime? arrivalDateTime,
    required String pilotFunction,
    required int ifrApproaches,
    required String approachType,
    required int takeOffsDays,
    required int takeOffsNight,
    required int landingsDay,
    required int landingsNight,
    required int timeBlockMinutes,
    required int timeTotalBlockMinutes,
    required int timeFlightMinutes,
    required int timePICMinutes,
    required int timePICUSMinutes,
    required int timeSICMinutes,
    required int timeDualMinutes,
    required int timeInstructorMinutes,
    required int timeIFRMinutes,
    required int timeInstrumentMinutes,
    required int timeSimulatedInstrumentMinutes,
    required int timeNightMinutes,
    required int timeCrossCountryMinutes,
    required int timeCustom1Minutes,
    required int timeCustom2Minutes,
    required int timeCustom3Minutes,
    required int timeCustom4Minutes,
    required int distanceNM,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
  }) {
    return _repository.updateFlight(
      flight: flight,
      aircraftId: aircraftId,
      departureAirportId: departureAirportId,
      arrivalAirportId: arrivalAirportId,
      departureDateTime: departureDateTime,
      takeOffDateTime: takeOffDateTime,
      landingDateTime: landingDateTime,
      arrivalDateTime: arrivalDateTime,
      pilotFunction: pilotFunction,
      ifrApproaches: ifrApproaches,
      approachType: approachType,
      takeOffsDays: takeOffsDays,
      takeOffsNight: takeOffsNight,
      landingsDay: landingsDay,
      landingsNight: landingsNight,
      timeBlockMinutes: timeBlockMinutes,
      timeTotalBlockMinutes: timeTotalBlockMinutes,
      timeFlightMinutes: timeFlightMinutes,
      timePICMinutes: timePICMinutes,
      timePICUSMinutes: timePICUSMinutes,
      timeSICMinutes: timeSICMinutes,
      timeDualMinutes: timeDualMinutes,
      timeInstructorMinutes: timeInstructorMinutes,
      timeIFRMinutes: timeIFRMinutes,
      timeInstrumentMinutes: timeInstrumentMinutes,
      timeSimulatedInstrumentMinutes: timeSimulatedInstrumentMinutes,
      timeNightMinutes: timeNightMinutes,
      timeCrossCountryMinutes: timeCrossCountryMinutes,
      timeCustom1Minutes: timeCustom1Minutes,
      timeCustom2Minutes: timeCustom2Minutes,
      timeCustom3Minutes: timeCustom3Minutes,
      timeCustom4Minutes: timeCustom4Minutes,
      distanceNM: distanceNM,
      remarks: remarks,
      notes: notes,
      crewAssignments: crewAssignments,
    );
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
  Future<List<String>> fetchSimulatorCrewLabels(int simulatorId) =>
      _repository.fetchSimulatorCrewLabels(simulatorId);
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
