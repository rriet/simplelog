import 'package:drift/drift.dart';

import 'package:simplelog/data/database/converters/crew_position_converter.dart';
import 'package:simplelog/data/database/tables/crew_table.dart';
import 'package:simplelog/data/database/tables/simulator_trainings_table.dart';

const String _positionConstraint =
    "CHECK(position IN ('pic','picus','sic','trainee','instructor', "
    "'observer','relief','relief_captain','relief_first_officer',"
    "'cabin_senior','cabin_crew','other'))";

/// Join table linking simulator sessions with assigned crew members.
class SimulatorCrewAssignments extends Table {
  /// Primary key for the assignment row.
  IntColumn get id => integer().autoIncrement()();

  /// Referenced simulator training session.
  IntColumn get simulatorId => integer().references(
    SimulatorTrainings,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();

  /// Referenced crew member.
  IntColumn get crewId => integer().references(
    Crew,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();

  /// Crew role encoded using [CrewPositionConverter].
  TextColumn get position => text().map(const CrewPositionConverter())();

  @override
  List<String> get customConstraints => const [_positionConstraint];
}
