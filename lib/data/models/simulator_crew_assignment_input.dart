import 'package:simplelog/data/database/enums/crew_position.dart';

/// Input payload used to create or update a simulator crew assignment row.
class SimulatorCrewAssignmentInput {
  /// Creates a crew assignment input with the selected crew member and role.
  const SimulatorCrewAssignmentInput({
    required this.crewId,
    required this.position,
    // Keep immutable to safely pass between UI and repository layers.
  });

  /// Referenced crew member identifier.
  final int crewId;

  /// Crew position for the assignment (for example PIC or SIC).
  final CrewPosition position;
}
