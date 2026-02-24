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

/// Abstraction over logbook persistence and query operations.
abstract class LogbookRepositoryContract {
  /// Watches the logbook entries that match the given [filters].
  Stream<List<LogbookEntry>> watchLogbook(LogbookFilters filters);

  /// Fetches a single page of logbook entries for the given [filters].
  Future<List<LogbookEntry>> fetchLogbookPage(
    LogbookFilters filters, {
    required int limit,
    required int offset,
  });

  /// Returns the earliest event date in the logbook, if any.
  Future<DateTime?> fetchFirstEventDate();

  /// Looks up an entry by its timeline row id.
  Future<LogbookEntry?> fetchEntryByTimelineId(int timeLineId);

  /// Finds a flight by its id.
  Future<Flight?> findFlightById(int flightId);

  /// Loads all data needed to edit a flight.
  Future<FlightEditData?> loadFlightEditData(int flightId);

  /// Returns all crew assignments for the given [flightId].
  Future<List<FlightCrewAssignment>> fetchFlightCrewAssignments(int flightId);

  /// Toggles the locked state for the given [entry].
  Future<void> toggleEntryLock(LogbookEntry entry);

  /// Toggles the locked state for a duty period by [dutyId].
  Future<void> toggleDutyLock(int dutyId);

  /// Finds a duty period by id.
  Future<DutyPeriod?> findDutyById(int dutyId);

  /// Loads data needed to edit a duty period.
  Future<DutyEditData?> loadDutyEditData(int dutyId);

  /// Loads data needed to edit a positioning entry.
  Future<PositioningEditData?> loadPositioningEditData(int positioningId);

  /// Finds a positioning entry by id.
  Future<Positioning?> findPositioningById(int positioningId);

  /// Finds a simulator training entry by id.
  Future<SimulatorTraining?> findSimulatorTrainingById(int simulatorId);

  /// Loads data needed to edit a simulator training entry.
  Future<SimulatorEditData?> loadSimulatorEditData(int simulatorId);

  /// Fetches all simulator crew assignments for the given [simulatorId].
  Future<List<SimulatorCrewAssignment>> fetchSimulatorCrewAssignments(
    int simulatorId,
  );

  /// Creates a duty period with the provided times and factored value.
  Future<void> createDuty({
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  });

  /// Updates an existing duty period with new timing information.
  Future<void> updateDuty({
    required DutyPeriod duty,
    required DateTime start,
    required DateTime end,
    required int dutyMinutes,
    required int factoredMinutes,
  });

  /// Creates a new positioning entry between two airports.
  Future<void> createPositioning({
    required int departureAirportId,
    required int arrivalAirportId,
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int totalMinutes,
    required String notes,
  });

  /// Updates an existing positioning entry.
  Future<void> updatePositioning({
    required Positioning positioning,
    required DateTime departureDateTime,
    required DateTime? arrivalDateTime,
    required int departureAirportId,
    required int arrivalAirportId,
    required int totalMinutes,
    required String notes,
  });

  /// Creates a new flight from the given [input].
  Future<void> createFlight({
    required FlightWriteInput input,
  });

  /// Updates an existing [flight] with the given [input] data.
  Future<void> updateFlight({
    required Flight flight,
    required FlightWriteInput input,
  });

  /// Creates a simulator training entry and associated crew assignments.
  Future<void> createSimulatorTraining({
    required int aircraftId,
    required DateTime startDateTime,
    required DateTime? endDateTime,
    required int totalMinutes,
    required String remarks,
    required String notes,
    required List<SimulatorCrewAssignmentInput> crewAssignments,
  });

  /// Updates an existing simulator training entry.
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

  /// Resolves human‑readable crew labels for a flight.
  Future<List<String>> fetchFlightCrewLabels(int flightId);

  /// Returns detailed crew info items for a flight.
  Future<List<CrewInfoItem>> fetchFlightCrewInfo(int flightId);

  /// Resolves human‑readable crew labels for a simulator session.
  Future<List<String>> fetchSimulatorCrewLabels(int simulatorId);

  /// Returns detailed crew info items for a simulator session.
  Future<List<CrewInfoItem>> fetchSimulatorCrewInfo(int simulatorId);

  /// Fetches all entries that reference the given [airportId].
  Future<List<LogbookEntry>> fetchEntriesForAirport(int airportId);

  /// Fetches a page of entries for [airportId].
  Future<List<LogbookEntry>> fetchEntriesForAirportPage(
    int airportId, {
    required int limit,
    required int offset,
  });

  /// Computes a flight‑time summary for a specific airport.
  Future<LogbookFlightSummary> fetchFlightSummaryForAirport(int airportId);

  /// Fetches all entries that reference the given [aircraftId].
  Future<List<LogbookEntry>> fetchEntriesForAircraft(int aircraftId);

  /// Fetches a page of entries for [aircraftId].
  Future<List<LogbookEntry>> fetchEntriesForAircraftPage(
    int aircraftId, {
    required int limit,
    required int offset,
  });

  /// Computes a flight‑time summary for a specific aircraft.
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraft(int aircraftId);

  /// Fetches all entries for the given [aircraftTypeId].
  Future<List<LogbookEntry>> fetchEntriesForAircraftType(int aircraftTypeId);

  /// Fetches a page of entries for [aircraftTypeId].
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypePage(
    int aircraftTypeId, {
    required int limit,
    required int offset,
  });

  /// Computes a flight‑time summary for a specific aircraft type.
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftType(
    int aircraftTypeId,
  );

  /// Fetches a page of entries for the provided aircraft type ids.
  Future<List<LogbookEntry>> fetchEntriesForAircraftTypeFamilyPage(
    List<int> aircraftTypeIds, {
    required int limit,
    required int offset,
  });

  /// Computes flight‑time summary across a family of aircraft types.
  Future<LogbookFlightSummary> fetchFlightSummaryForAircraftTypeFamily(
    List<int> aircraftTypeIds,
  );

  /// Fetches all entries involving the given crew member.
  Future<List<LogbookEntry>> fetchEntriesForCrew(int crewId);

  /// Fetches a page of entries for the given crew member.
  Future<List<LogbookEntry>> fetchEntriesForCrewPage(
    int crewId, {
    required int limit,
    required int offset,
  });

  /// Computes a flight‑time summary for the given crew member.
  Future<LogbookFlightSummary> fetchFlightSummaryForCrew(int crewId);

  /// Deletes the given [entry] and any associated domain rows.
  Future<void> deleteEntry(LogbookEntry entry);

  /// Deletes a duty period and associated timeline rows.
  Future<void> deleteDutyById(int dutyId);
}
