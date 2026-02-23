import 'package:drift/drift.dart';

import 'package:simplelog/data/database/converters/crew_position_converter.dart';
import 'package:simplelog/data/database/tables/crew_table.dart';
import 'package:simplelog/data/database/tables/simulator_trainings_table.dart';

const String _positionConstraint =
    "CHECK(position IN ('pic','picus','sic','trainee','instructor', "
    "'observer','relief','relief_captain','relief_first_officer',"
    "'cabin_senior','cabin_crew','other'))";

/// Public API documentation.
class SimulatorCrewAssignments extends Table {
  /// Public API documentation.
  IntColumn get id => integer().autoIncrement()();
  /// Public API documentation.
  IntColumn get simulatorId => integer().references(SimulatorTrainings, #id)();
  /// Public API documentation.
  IntColumn get crewId => integer().references(Crew, #id)();
  /// Public API documentation.
  TextColumn get position => text().map(const CrewPositionConverter())();

  @override
  List<String> get customConstraints => const [_positionConstraint];
}
