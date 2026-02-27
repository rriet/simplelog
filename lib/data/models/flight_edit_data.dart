import 'package:simplelog/data/database/app_database.dart';

/// Aggregated data needed by flight edit UI.
class FlightEditData {
  /// Creates flight edit payload.
  const FlightEditData({
    required this.flight,
    required this.departureLine,
    required this.crewAssignments,
  });

  /// Flight row being edited.
  final Flight flight;
  /// Timeline row for departure/chocks-off.
  final TimeLine? departureLine;
  /// Assigned crew rows.
  final List<FlightCrewAssignment> crewAssignments;
}
