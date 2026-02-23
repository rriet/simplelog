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

/// Public API documentation.
abstract class LogbookRepositoryContract {
  /// Public API documentation.
  Stream<List<LogbookEntry>> watchLogbook(LogbookFilters filters);

  /// Public API documentation.
  Future<List<LogbookEntry>> fetchLogbookPage(
    LogbookFilters filters, {
    required int limit,
    /// Public API documentation.
    required int offset,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  Future<DateTime?> fetchFirstEventDate();
  /// Public API documentation.
  Future<LogbookEntry?> fetchEntryByTimelineId(int timeLineId);
  /// Public API documentation.
  Future<Flight?> findFlightById(int flightId);
  /// Public API documentation.
  Future<FlightEditData?> loadFlightEditData(int flightId);
  /// Public API documentation.
  Future<List<FlightCrewAssignment>> fetchFlightCrewAssignments(int flightId);
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleEntryLock(LogbookEntry entry);
  /// Public API documentation.
  Future<void> toggleDutyLock(int dutyId);
  /// Public API documentation.
  Future<DutyPeriod?> findDutyById(int dutyId);
  /// Public API documentation.
  Future<DutyEditData?> loadDutyEditData(int dutyId);
  /// Public API documentation.
  Future<PositioningEditData?> loadPositioningEditData(int positioningId);
  /// Public API documentation.
  Future<Positioning?> findPositioningById(int positioningId);
  /// Public API documentation.
  Future<SimulatorTraining?> findSimulatorTrainingById(int simulatorId);
  /// Public API documentation.
  Future<SimulatorEditData?> loadSimulatorEditData(int simulatorId);
  /// Public API documentation.
  Future<List<SimulatorCrewAssignment>> fetchSimulatorCrewAssignments(
    int simulatorId,
  /// Public API documentation.
  );

  /// Public API documentation.
  Future<void> createDuty({
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  });
/// Public API documentation.

  /// Public API documentation.
  Future<void> updateDuty({
    required DutyPeriod duty,
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  });

  /// Public API documentation.
  Future<void> createPositioning({
    required int departureAirportId,
    required int arrivalAirportId,
    /// Public API documentation.
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int totalMinutes,
    required String notes,
  });
/// Public API documentation.

  /// Public API documentation.
  Future<void> updatePositioning({
    required Positioning positioning,
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int departureAirportId,
    required int arrivalAirportId,
    required int totalMinutes,
    required String notes,
  /// Public API documentation.
  });

  /// Public API documentation.
  Future<void> createFlight({
    required FlightWriteInput input,
  });

  /// Public API documentation.
  Future<void> updateFlight({
    required Flight flight,
    required FlightWriteInput input,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  Future<void> createSimulatorTraining({
    /// Public API documentation.
    required int aircraftId,
    /// Public API documentation.
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    /// Public API documentation.
    required List<SimulatorCrewAssignmentInput> crewAssignments,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  Future<void> updateSimulatorTraining({
    required SimulatorTraining simulatorTraining,
    required int aircraftId,
    /// Public API documentation.
    required DateTime startDateTime,
    /// Public API documentation.
    required DateTime? endDateTime,
    /// Public API documentation.
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
  });
/// Public API documentation.

  /// Public API documentation.
  Future<List<String>> fetchFlightCrewLabels(int flightId);
  /// Public API documentation.
  Future<List<CrewInfoItem>> fetchFlightCrewInfo(int flightId);
  /// Public API documentation.
  Future<List<String>> fetchSimulatorCrewLabels(int simulatorId);
  /// Public API documentation.
  Future<List<CrewInfoItem>> fetchSimulatorCrewInfo(int simulatorId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAirport(int airportId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAirportPage(
    int airportId, {
    required int limit,
    required int offset,
  });
  /// Public API documentation.
  Future<LogbookFlightSummary> fetchFlightSummaryForAirport(int airportId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAircraft(int aircraftId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAircraftPage(
    int aircraftId, {
    required int limit,
    required int offset,
  });
  /// Public API documentation.
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraft(int aircraftId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAircraftType(int aircraftTypeId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypePage(
    int aircraftTypeId, {
    required int limit,
    required int offset,
  });
  /// Public API documentation.
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftType(
    int aircraftTypeId,
  );
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypeFamilyPage(
    List<int> aircraftTypeIds, {
    required int limit,
    required int offset,
  });
  /// Public API documentation.
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftTypeFamily(
    List<int> aircraftTypeIds,
  );
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForCrew(int crewId);
  /// Public API documentation.
  Future<List<LogbookEntry>> fetchEntriesForCrewPage(
    int crewId, {
    required int limit,
    required int offset,
  });
  /// Public API documentation.
  Future<LogbookFlightSummary> fetchFlightSummaryForCrew(int crewId);

  /// Public API documentation.
  Future<void> deleteEntry(LogbookEntry entry);
  /// Public API documentation.
  Future<void> deleteDutyById(int dutyId);
}
