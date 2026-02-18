import 'package:simplelog/data/database/app_database.dart';

class FlightEditData {
  const FlightEditData({
    required this.flight,
    required this.departureLine,
    required this.crewAssignments,
  });

  final Flight flight;
  final TimeLine? departureLine;
  final List<FlightCrewAssignment> crewAssignments;
}

