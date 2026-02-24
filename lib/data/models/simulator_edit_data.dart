import 'package:simplelog/data/database/app_database.dart';

/// Aggregate data needed to edit a simulator training entry.
class SimulatorEditData {
  /// Creates a view model for editing a simulator training session.
  const SimulatorEditData({
    required this.simulatorTraining,
    required this.startLine,
    required this.crewAssignments,
  });

  /// The simulator training record being edited.
  final SimulatorTraining simulatorTraining;

  /// Optional starting point in the timeline for this training.
  final TimeLine? startLine;

  /// Crew assignments associated with the simulator session.
  final List<SimulatorCrewAssignment> crewAssignments;
}
