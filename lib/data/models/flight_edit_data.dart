import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
class FlightEditData {
  /// Public API documentation.
  const FlightEditData({
    required this.flight,
    required this.departureLine,
    required this.crewAssignments,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final Flight flight;
  /// Public API documentation.
  final TimeLine? departureLine;
  /// Public API documentation.
  final List<FlightCrewAssignment> crewAssignments;
}
