import 'package:drift/drift.dart';

import '../converters/crew_position_converter.dart';
import 'crew_table.dart';
import 'flights_table.dart';

class FlightCrewAssignments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get flightId => integer().references(Flights, #id)();
  IntColumn get crewId => integer().references(Crew, #id)();
  TextColumn get position => text().map(const CrewPositionConverter())();

  @override
  // Enforces valid crew positions in the DB. 'unknown' is only used in Dart.
  List<String> get customConstraints => const [
        "CHECK(position IN ('pic','sic','instructor','observer','relief','relief_captain','relief_first_officer','cabin_senior','cabin_crew','other'))",
      ];
}
