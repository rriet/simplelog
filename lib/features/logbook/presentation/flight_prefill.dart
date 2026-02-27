import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';

/// Optional defaults passed to flight/simulator forms.
class FlightPrefill {
  /// Creates a prefill payload.
  const FlightPrefill({
    this.aircraftId,
    this.fromAirportId,
    this.toAirportId,
    this.chocksOff,
    this.crewAssignments = const <SimulatorCrewAssignmentInput>[],
  });

  /// Prefilled aircraft id.
  final int? aircraftId;
  /// Prefilled departure airport id.
  final int? fromAirportId;
  /// Prefilled arrival airport id.
  final int? toAirportId;
  /// Prefilled chocks-off time.
  final DateTime? chocksOff;
  /// Prefilled crew assignments.
  final List<SimulatorCrewAssignmentInput> crewAssignments;
}
