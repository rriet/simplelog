import 'package:simplelog/data/database/app_database.dart';

class SimulatorEditData {
  const SimulatorEditData({
    required this.simulatorTraining,
    required this.startLine,
    required this.crewAssignments,
  });

  final SimulatorTraining simulatorTraining;
  final TimeLine? startLine;
  final List<SimulatorCrewAssignment> crewAssignments;
}
