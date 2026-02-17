import 'package:drift/drift.dart';

import '../converters/crew_position_converter.dart';
import 'crew_table.dart';
import 'simulator_trainings_table.dart';

class SimulatorCrewAssignments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get simulatorId =>
      integer().references(SimulatorTrainings, #id)();
  IntColumn get crewId => integer().references(Crew, #id)();
  TextColumn get position => text().map(const CrewPositionConverter())();

  @override
  List<String> get customConstraints => const [
        "CHECK(position IN ('pic','sic','instructor','observer','relief','relief_captain','relief_first_officer','cabin_senior','cabin_crew','other'))",
      ];
}
