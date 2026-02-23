import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
class SimulatorEditData {
  /// Public API documentation.
  const SimulatorEditData({
    required this.simulatorTraining,
    required this.startLine,
    required this.crewAssignments,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final SimulatorTraining simulatorTraining;
  /// Public API documentation.
  final TimeLine? startLine;
  /// Public API documentation.
  final List<SimulatorCrewAssignment> crewAssignments;
}
