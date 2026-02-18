import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/duty_edit_data.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/data/models/flight_edit_data.dart';
import 'package:simplelog/data/models/positioning_edit_data.dart';
import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';
import 'package:simplelog/data/models/simulator_edit_data.dart';

abstract class LogbookRepositoryContract {
  Stream<List<LogbookEntry>> watchLogbook(LogbookFilters filters);

  Future<List<LogbookEntry>> fetchLogbookPage(
    LogbookFilters filters, {
    required int limit,
    required int offset,
  });

  Future<DateTime?> fetchFirstEventDate();
  Future<LogbookEntry?> fetchEntryByTimelineId(int timeLineId);
  Future<Flight?> findFlightById(int flightId);
  Future<FlightEditData?> loadFlightEditData(int flightId);
  Future<List<FlightCrewAssignment>> fetchFlightCrewAssignments(int flightId);

  Future<void> toggleEntryLock(LogbookEntry entry);
  Future<void> toggleDutyLock(int dutyId);
  Future<DutyPeriod?> findDutyById(int dutyId);
  Future<DutyEditData?> loadDutyEditData(int dutyId);
  Future<PositioningEditData?> loadPositioningEditData(int positioningId);
  Future<Positioning?> findPositioningById(int positioningId);
  Future<SimulatorTraining?> findSimulatorTrainingById(int simulatorId);
  Future<SimulatorEditData?> loadSimulatorEditData(int simulatorId);
  Future<List<SimulatorCrewAssignment>> fetchSimulatorCrewAssignments(
    int simulatorId,
  );

  Future<void> createDuty({
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  });

  Future<void> updateDuty({
    required DutyPeriod duty,
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  });

  Future<void> createPositioning({
    required int departureAirportId,
    required int arrivalAirportId,
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int totalMinutes,
    required String notes,
  });

  Future<void> updatePositioning({
    required Positioning positioning,
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int departureAirportId,
    required int arrivalAirportId,
    required int totalMinutes,
    required String notes,
  });

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
  });

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
  });

  Future<void> createSimulatorTraining({
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
  });

  Future<void> updateSimulatorTraining({
    required SimulatorTraining simulatorTraining,
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
  });

  Future<List<String>> fetchFlightCrewLabels(int flightId);
  Future<List<String>> fetchSimulatorCrewLabels(int simulatorId);
  Future<List<LogbookEntry>> fetchEntriesForAirport(int airportId);
  Future<List<LogbookEntry>> fetchEntriesForAircraft(int aircraftId);
  Future<List<LogbookEntry>> fetchEntriesForCrew(int crewId);

  Future<void> deleteEntry(LogbookEntry entry);
  Future<void> deleteDutyById(int dutyId);
}
