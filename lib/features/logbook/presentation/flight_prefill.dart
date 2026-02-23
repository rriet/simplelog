import 'package:simplelog/data/models/simulator_crew_assignment_input.dart';

/// Public API documentation.
class FlightPrefill {
  /// Public API documentation.
  const FlightPrefill({
    this.aircraftId,
    this.fromAirportId,
    this.toAirportId,
    this.chocksOff,
    this.crewAssignments = const <SimulatorCrewAssignmentInput>[],
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final int? aircraftId;
  /// Public API documentation.
  final int? fromAirportId;
  /// Public API documentation.
  final int? toAirportId;
  /// Public API documentation.
  final DateTime? chocksOff;
  /// Public API documentation.
  final List<SimulatorCrewAssignmentInput> crewAssignments;
}
