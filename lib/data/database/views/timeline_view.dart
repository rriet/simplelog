import 'package:drift/drift.dart';

import '../app_database.dart';

extension TimelineViewQueries on AppDatabase {
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
