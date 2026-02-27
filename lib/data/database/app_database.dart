import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:simplelog/data/database/converters/aircraft_category_converter.dart';
import 'package:simplelog/data/database/converters/crew_position_converter.dart';
import 'package:simplelog/data/database/converters/engine_type_converter.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/database/tables/aircraft_types_table.dart';
import 'package:simplelog/data/database/tables/aircrafts_table.dart';
import 'package:simplelog/data/database/tables/airports_table.dart';
import 'package:simplelog/data/database/tables/crew_table.dart';
import 'package:simplelog/data/database/tables/duty_periods_table.dart';
import 'package:simplelog/data/database/tables/flight_crew_assignments_table.dart';
import 'package:simplelog/data/database/tables/flights_table.dart';
import 'package:simplelog/data/database/tables/limit_rules_table.dart';
import 'package:simplelog/data/database/tables/positionings_table.dart';
import 'package:simplelog/data/database/tables/previous_experiences_table.dart';
import 'package:simplelog/data/database/tables/report_templates_table.dart';
import 'package:simplelog/data/database/tables/rule_snapshots_table.dart';
import 'package:simplelog/data/database/tables/simulator_crew_assignments_table.dart';
import 'package:simplelog/data/database/tables/simulator_trainings_table.dart';
import 'package:simplelog/data/database/tables/timeline_table.dart';
import 'package:simplelog/data/database/tables/user_profiles_table.dart';

part 'app_database.g.dart';

/// Drift database base file name.
const appDatabaseFileName = 'simplelog_v1';

@DriftDatabase(
  tables: [
    AircraftTypes,
    Aircrafts,
    Airports,
    Flights,
    LimitRules,
    RuleSnapshots,
    Positionings,
    PreviousExperiences,
    ReportTemplates,
    DutyPeriods,
    Crew,
    FlightCrewAssignments,
    SimulatorCrewAssignments,
    SimulatorTrainings,
    TimeLines,
    UserProfiles,
  ],
)
/// Public API documentation.
class AppDatabase extends _$AppDatabase {
  /// Public API documentation.
  AppDatabase() : super(driftDatabase(name: appDatabaseFileName));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(flights, flights.endorsementData);
        await migrator.addColumn(flights, flights.endorsementHash);
        await migrator.addColumn(
          simulatorTrainings,
          simulatorTrainings.endorsementData,
        );
        await migrator.addColumn(
          simulatorTrainings,
          simulatorTrainings.endorsementHash,
        );
      }
    },
  );

  /// Public API documentation.
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(flightCrewAssignments).go();
      await delete(simulatorCrewAssignments).go();
      await delete(ruleSnapshots).go();
      await delete(limitRules).go();
      await delete(previousExperiences).go();
      await delete(flights).go();
      await delete(simulatorTrainings).go();
      await delete(positionings).go();
      await delete(dutyPeriods).go();
      await delete(timeLines).go();
      await delete(aircrafts).go();
      await delete(aircraftTypes).go();
      await delete(airports).go();
      await delete(crew).go();
      await delete(userProfiles).go();
    });
  }

  /// verifies that a single time_lines row is linked to exactly
  /// one event in the database. prevents one timestamp record
  /// from being reused incorrectly across different logbook entries.
  Future<void> assertTimelineUniqueness(int timeLineId) async {
    final results = await Future.wait([
      _countByTimelineId(flights, flights.departureDateTimeId, timeLineId),
      _countByTimelineId(
        positionings,
        positionings.departureDateTimeId,
        timeLineId,
      ),
      _countByTimelineId(
        simulatorTrainings,
        simulatorTrainings.startTimeLineId,
        timeLineId,
      ),
      _countByTimelineId(
        dutyPeriods,
        dutyPeriods.dutyStartTimeLineId,
        timeLineId,
      ),
      _countByTimelineId(
        dutyPeriods,
        dutyPeriods.dutyEndTimeLineId,
        timeLineId,
      ),
    ]);

    final flightCount = results[0];
    final positioningCount = results[1];
    final simulatorCount = results[2];
    final dutyStartCount = results[3];
    final dutyEndCount = results[4];

    final total =
        flightCount +
        positioningCount +
        simulatorCount +
        dutyStartCount +
        dutyEndCount;

    if (total != 1) {
      throw StateError(
        'Timeline $timeLineId must be referenced by exactly one event. '
        'Found: flights=$flightCount, positionings=$positioningCount, '
        'simulators=$simulatorCount, dutyStart=$dutyStartCount, '
        'dutyEnd=$dutyEndCount.',
      );
    }
  }

  Future<int> _countByTimelineId<T extends Table, D>(
    TableInfo<T, D> table,
    IntColumn column,
    int timeLineId,
  ) async {
    final countExpression = column.count();
    final query = selectOnly(table)
      ..addColumns([countExpression])
      ..where(column.equals(timeLineId));
    final row = await query.getSingle();
    return row.read(countExpression) ?? 0;
  }
}
