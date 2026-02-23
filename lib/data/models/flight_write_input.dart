import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';

/// Public API documentation.
class FlightWriteInput {
  /// Public API documentation.
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
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final int aircraftId;
  /// Public API documentation.
  final int departureAirportId;
  /// Public API documentation.
  final int arrivalAirportId;
  /// Public API documentation.
  final DateTime departureDateTime;
  /// Public API documentation.
  final DateTime? takeOffDateTime;
  /// Public API documentation.
  final DateTime? landingDateTime;
  /// Public API documentation.
  final DateTime? arrivalDateTime;
  /// Public API documentation.
  final String pilotFunction;
  /// Public API documentation.
  final int ifrApproaches;
  /// Public API documentation.
  final String approachType;
  /// Public API documentation.
  final int takeOffsDays;
  /// Public API documentation.
  final int takeOffsNight;
  /// Public API documentation.
  final int landingsDay;
  /// Public API documentation.
  final int landingsNight;
  /// Public API documentation.
  final int timeBlockMinutes;
  /// Public API documentation.
  final int timeTotalBlockMinutes;
  /// Public API documentation.
  final int timeFlightMinutes;
  /// Public API documentation.
  final int timePICMinutes;
  /// Public API documentation.
  final int timePICUSMinutes;
  /// Public API documentation.
  final int timeSICMinutes;
  /// Public API documentation.
  final int timeDualMinutes;
  /// Public API documentation.
  final int timeInstructorMinutes;
  /// Public API documentation.
  final int timeIFRMinutes;
  /// Public API documentation.
  final int timeInstrumentMinutes;
  /// Public API documentation.
  final int timeSimulatedInstrumentMinutes;
  /// Public API documentation.
  final int timeNightMinutes;
  /// Public API documentation.
  final int timeCrossCountryMinutes;
  /// Public API documentation.
  final int timeCustom1Minutes;
  /// Public API documentation.
  final int timeCustom2Minutes;
  /// Public API documentation.
  final int timeCustom3Minutes;
  /// Public API documentation.
  final int timeCustom4Minutes;
  /// Public API documentation.
  final int distanceNM;
  /// Public API documentation.
  final String remarks;
  /// Public API documentation.
  final String notes;
  /// Public API documentation.
  final List<SimulatorCrewAssignmentInput> crewAssignments;
}
