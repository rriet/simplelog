import 'package:drift/drift.dart';

import 'package:simplelog/data/database/app_database.dart';

/// Query helpers that build timeline-centric joined statements.
extension TimelineViewQueries on AppDatabase {
  /// Builds the base timeline query with related event and crew joins.
  JoinedSelectStatement<HasResultSet, dynamic> getTimeline() {
    final departureAirport = alias(airports, 'departure_airports');
    final arrivalAirport = alias(airports, 'arrival_airports');

    final query = select(timeLines).join([
      leftOuterJoin(
        flights,
        flights.departureDateTimeId.equalsExp(timeLines.id),
      ),
      leftOuterJoin(
        departureAirport,
        departureAirport.id.equalsExp(flights.departureAirportId),
      ),
      leftOuterJoin(
        arrivalAirport,
        arrivalAirport.id.equalsExp(flights.arrivalAirportId),
      ),
      leftOuterJoin(
        flightCrewAssignments,
        flightCrewAssignments.flightId.equalsExp(flights.id),
      ),
      leftOuterJoin(
        crew,
        crew.id.equalsExp(flightCrewAssignments.crewId),
      ),
      leftOuterJoin(
        dutyPeriods,
        dutyPeriods.dutyStartTimeLineId.equalsExp(timeLines.id),
      ),
      leftOuterJoin(
        simulatorTrainings,
        simulatorTrainings.startTimeLineId.equalsExp(timeLines.id),
      ),
    ]);

    return query;
  }
}
