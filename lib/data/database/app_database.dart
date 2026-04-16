import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:simplelog/data/database/converters/aircraft_category_converter.dart';
import 'package:simplelog/data/database/converters/crew_position_converter.dart';
import 'package:simplelog/data/database/converters/engine_type_converter.dart';
import 'package:simplelog/data/database/converters/pilot_function_converter.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/database/enums/pilot_function.dart';
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
const appDatabaseFileName = 'simplelog_v0';

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
/// Main Drift database used by the application.
class AppDatabase extends _$AppDatabase {
  /// Creates the application database with the configured file name.
  AppDatabase() : super(driftDatabase(name: appDatabaseFileName));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await _dropFlightsInstrumentMinutesColumnIfPresent();
      }
      if (from < 3) {
        await _dropPreviousExperiencesInstrumentMinutesColumnIfPresent();
      }
      if (from < 4) {
        await _dropFlightsSimulatedInstrumentMinutesColumnIfPresent();
        await _dropPreviousExperiencesSimulatedInstrumentMinutesColumnIfPresent(
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _createLockWriteBypassTableIfNeeded();
      await _installLockProtectionTriggers();
      await _assertForeignKeyIntegrity();
    },
  );

  /// Runs [action] with lock-protection triggers bypassed for this connection.
  ///
  /// Intended for trusted full-replacement operations
  /// (for example, db restore).
  Future<T> runWithLockWriteBypass<T>(Future<T> Function() action) async {
    await _createLockWriteBypassTableIfNeeded();
    await customStatement(
      '''
INSERT OR IGNORE INTO lock_write_bypass(id, enabled)
VALUES (1, 0)
''',
    );
    await customStatement(
      'UPDATE lock_write_bypass SET enabled = 1 WHERE id=1',
    );
    try {
      return await action();
    } finally {
      await customStatement(
        'UPDATE lock_write_bypass SET enabled = 0 WHERE id=1',
      );
    }
  }

  /// Deletes user-managed data tables while preserving static templates.
  Future<void> clearAllData() async {
    await runWithLockWriteBypass(() async {
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

  Future<void> _createLockWriteBypassTableIfNeeded() async {
    await customStatement(
      '''
CREATE TABLE IF NOT EXISTS lock_write_bypass (
  id INTEGER PRIMARY KEY CHECK(id = 1),
  enabled INTEGER NOT NULL CHECK(enabled IN (0, 1))
)
''',
    );
    await customStatement(
      '''
INSERT OR IGNORE INTO lock_write_bypass(id, enabled)
VALUES (1, 0)
''',
    );
  }

  Future<void> _installLockProtectionTriggers() async {
    await _createLockProtectionTriggersForTable(tableName: 'aircraft_types');
    await _createLockProtectionTriggersForTable(tableName: 'aircrafts');
    await _createLockProtectionTriggersForTable(tableName: 'airports');
    await _createLockProtectionTriggersForTable(tableName: 'crew');
    await _createLockProtectionTriggersForTable(tableName: 'flights');
    await _createLockProtectionTriggersForTable(tableName: 'positionings');
    await _createLockProtectionTriggersForTable(
      tableName: 'simulator_trainings',
    );
    await _createLockProtectionTriggersForTable(tableName: 'duty_periods');
  }

  Future<void> _assertForeignKeyIntegrity() async {
    final rows = await customSelect('PRAGMA foreign_key_check').get();
    if (rows.isEmpty) return;
    throw StateError(
      'Foreign key integrity check failed with ${rows.length} violation(s).',
    );
  }

  Future<void> _dropFlightsInstrumentMinutesColumnIfPresent() async {
    final columnRows = await customSelect(
      "PRAGMA table_info('flights')",
    ).get();
    final hasColumn = columnRows.any(
      (row) => row.read<String>('name') == 'time_instrument_minutes',
    );
    if (!hasColumn) {
      return;
    }
    await customStatement(
      'ALTER TABLE flights DROP COLUMN time_instrument_minutes',
    );
  }

  Future<void>
  _dropPreviousExperiencesInstrumentMinutesColumnIfPresent() async {
    final columnRows = await customSelect(
      "PRAGMA table_info('previous_experiences')",
    ).get();
    final hasColumn = columnRows.any(
      (row) => row.read<String>('name') == 'time_instrument_minutes',
    );
    if (!hasColumn) {
      return;
    }
    await customStatement(
      'ALTER TABLE previous_experiences DROP COLUMN time_instrument_minutes',
    );
  }

  Future<void> _dropFlightsSimulatedInstrumentMinutesColumnIfPresent() async {
    final columnRows = await customSelect(
      "PRAGMA table_info('flights')",
    ).get();
    final hasColumn = columnRows.any(
      (row) => row.read<String>('name') == 'time_simulated_instrument_minutes',
    );
    if (!hasColumn) {
      return;
    }
    await customStatement(
      'ALTER TABLE flights DROP COLUMN time_simulated_instrument_minutes',
    );
  }

  Future<void>
  _dropPreviousExperiencesSimulatedInstrumentMinutesColumnIfPresent() async {
    final columnRows = await customSelect(
      "PRAGMA table_info('previous_experiences')",
    ).get();
    final hasColumn = columnRows.any(
      (row) => row.read<String>('name') == 'time_simulated_instrument_minutes',
    );
    if (!hasColumn) {
      return;
    }
    await customStatement(
      'ALTER TABLE previous_experiences '
      'DROP COLUMN time_simulated_instrument_minutes',
    );
  }

  Future<void> _createLockProtectionTriggersForTable({
    required String tableName,
  }) async {
    final updateTrigger = 'trg_${tableName}_locked_update_block';
    final deleteTrigger = 'trg_${tableName}_locked_delete_block';
    await customStatement(
      '''
CREATE TRIGGER IF NOT EXISTS $updateTrigger
BEFORE UPDATE ON $tableName
FOR EACH ROW
WHEN OLD.is_locked = 1
  AND NEW.is_locked = OLD.is_locked
  AND COALESCE((SELECT enabled FROM lock_write_bypass WHERE id = 1), 0) = 0
BEGIN
  SELECT RAISE(ABORT, 'Locked row cannot be modified');
END
''',
    );
    await customStatement(
      '''
CREATE TRIGGER IF NOT EXISTS $deleteTrigger
BEFORE DELETE ON $tableName
FOR EACH ROW
WHEN OLD.is_locked = 1
  AND COALESCE((SELECT enabled FROM lock_write_bypass WHERE id = 1), 0) = 0
BEGIN
  SELECT RAISE(ABORT, 'Locked row cannot be deleted');
END
''',
    );
  }
}
