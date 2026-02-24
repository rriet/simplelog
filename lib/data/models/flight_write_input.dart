import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';

/// Input data used when creating or updating a flight log entry.
class FlightWriteInput {
  /// Creates a new payload with all values required to persist a flight.
  const FlightWriteInput({
    required this.aircraftId,
    required this.departureAirportId,
    required this.arrivalAirportId,
    required this.departureDateTime,
    required this.takeOffDateTime,
    required this.landingDateTime,
    required this.arrivalDateTime,
    required this.pilotFunction,
    required this.ifrApproaches,
    required this.approachType,
    required this.takeOffsDays,
    required this.takeOffsNight,
    required this.landingsDay,
    required this.landingsNight,
    required this.timeBlockMinutes,
    required this.timeTotalBlockMinutes,
    required this.timeFlightMinutes,
    required this.timePICMinutes,
    required this.timePICUSMinutes,
    required this.timeSICMinutes,
    required this.timeDualMinutes,
    required this.timeInstructorMinutes,
    required this.timeIFRMinutes,
    required this.timeInstrumentMinutes,
    required this.timeSimulatedInstrumentMinutes,
    required this.timeNightMinutes,
    required this.timeCrossCountryMinutes,
    required this.timeCustom1Minutes,
    required this.timeCustom2Minutes,
    required this.timeCustom3Minutes,
    required this.timeCustom4Minutes,
    required this.distanceNM,
    required this.remarks,
    required this.notes,
    required this.crewAssignments,
  });

  /// Identifier of the aircraft used for this flight.
  final int aircraftId;

  /// Identifier of the departure airport.
  final int departureAirportId;

  /// Identifier of the arrival airport.
  final int arrivalAirportId;

  /// Scheduled departure date and time (block off).
  final DateTime departureDateTime;

  /// Actual take‑off time, if known.
  final DateTime? takeOffDateTime;

  /// Actual landing time, if known.
  final DateTime? landingDateTime;

  /// Time of block‑on / arrival at the stand, if known.
  final DateTime? arrivalDateTime;

  /// Pilot function for this leg (e.g. PIC, SIC, dual).
  final String pilotFunction;

  /// Number of instrument approaches flown.
  final int ifrApproaches;

  /// Type of approach flown (e.g. ILS, RNAV).
  final String approachType;

  /// Number of day take‑offs.
  final int takeOffsDays;

  /// Number of night take‑offs.
  final int takeOffsNight;

  /// Number of day landings.
  final int landingsDay;

  /// Number of night landings.
  final int landingsNight;

  /// Block time for the leg in minutes.
  final int timeBlockMinutes;

  /// Cumulative block time including previous legs in minutes.
  final int timeTotalBlockMinutes;

  /// Airborne flight time (take‑off to landing) in minutes.
  final int timeFlightMinutes;

  /// PIC (pilot‑in‑command) time in minutes.
  final int timePICMinutes;

  /// PICUS (pilot‑in‑command under supervision) time in minutes.
  final int timePICUSMinutes;

  /// SIC (second‑in‑command) time in minutes.
  final int timeSICMinutes;

  /// Dual instruction time in minutes.
  final int timeDualMinutes;

  /// Time logged as instructor in minutes.
  final int timeInstructorMinutes;

  /// IFR time in minutes.
  final int timeIFRMinutes;

  /// Time in actual or simulated instruments in minutes.
  final int timeInstrumentMinutes;

  /// Time flown in simulated instruments in minutes.
  final int timeSimulatedInstrumentMinutes;

  /// Night time in minutes.
  final int timeNightMinutes;

  /// Cross‑country time in minutes.
  final int timeCrossCountryMinutes;

  /// Custom time bucket 1 in minutes.
  final int timeCustom1Minutes;

  /// Custom time bucket 2 in minutes.
  final int timeCustom2Minutes;

  /// Custom time bucket 3 in minutes.
  final int timeCustom3Minutes;

  /// Custom time bucket 4 in minutes.
  final int timeCustom4Minutes;

  /// Distance flown for the leg in nautical miles.
  final int distanceNM;

  /// Free‑form remarks about the leg.
  final String remarks;

  /// Private notes that are not printed in reports.
  final String notes;

  /// Crew assignments associated with this flight.
  final List<SimulatorCrewAssignmentInput> crewAssignments;
}
