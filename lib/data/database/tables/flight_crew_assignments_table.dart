import 'package:drift/drift.dart';

import 'package:simplelog/data/database/converters/crew_position_converter.dart';
import 'package:simplelog/data/database/tables/crew_table.dart';
import 'package:simplelog/data/database/tables/flights_table.dart';

const String _positionConstraint =
    "CHECK(position IN ('pic','picus','sic','trainee','instructor', "
    "'observer','relief','relief_captain','relief_first_officer',"
    "'cabin_senior','cabin_crew','other'))";

/// Join table linking flights with assigned crew members and positions.
class FlightCrewAssignments extends Table {
  /// Primary key for the assignment row.
  IntColumn get id => integer().autoIncrement()();

  /// Referenced flight.
  IntColumn get flightId => integer().references(Flights, #id)();

  /// Referenced crew member.
  IntColumn get crewId => integer().references(Crew, #id)();

  /// Crew role encoded using [CrewPositionConverter].
  TextColumn get position => text().map(const CrewPositionConverter())();

  @override
  // Enforces valid crew positions in the DB. 'unknown' is only used in Dart.
  List<String> get customConstraints => const [_positionConstraint];
}
