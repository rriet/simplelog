import 'package:simplelog/data/database/enums/crew_position.dart';

class SimulatorCrewAssignmentInput {
  const SimulatorCrewAssignmentInput({
    required this.crewId,
    required this.position,
  });

  final int crewId;
  final CrewPosition position;
}

