import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';

class FlightWriteInput {
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

  final int aircraftId;
  final int departureAirportId;
  final int arrivalAirportId;
  final DateTime departureDateTime;
  final DateTime? takeOffDateTime;
  final DateTime? landingDateTime;
  final DateTime? arrivalDateTime;
  final String pilotFunction;
  final int ifrApproaches;
  final String approachType;
  final int takeOffsDays;
  final int takeOffsNight;
  final int landingsDay;
  final int landingsNight;
  final int timeBlockMinutes;
  final int timeTotalBlockMinutes;
  final int timeFlightMinutes;
  final int timePICMinutes;
  final int timePICUSMinutes;
  final int timeSICMinutes;
  final int timeDualMinutes;
  final int timeInstructorMinutes;
  final int timeIFRMinutes;
  final int timeInstrumentMinutes;
  final int timeSimulatedInstrumentMinutes;
  final int timeNightMinutes;
  final int timeCrossCountryMinutes;
  final int timeCustom1Minutes;
  final int timeCustom2Minutes;
  final int timeCustom3Minutes;
  final int timeCustom4Minutes;
  final int distanceNM;
  final String remarks;
  final String notes;
  final List<SimulatorCrewAssignmentInput> crewAssignments;
}
