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
import 'package:simplelog/data/database/tables/rule_snapshots_table.dart';
import 'package:simplelog/data/database/tables/simulator_crew_assignments_table.dart';
import 'package:simplelog/data/database/tables/simulator_trainings_table.dart';
import 'package:simplelog/data/database/tables/timeline_table.dart';

part 'app_database.g.dart';

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
    DutyPeriods,
    Crew,
    FlightCrewAssignments,
    SimulatorCrewAssignments,
    SimulatorTrainings,
    TimeLines,
  ],
)
/// Public API documentation.
class AppDatabase extends _$AppDatabase {
  /// Public API documentation.
  AppDatabase() : super(driftDatabase(name: 'simplelog'));

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.database.customStatement('''
              CREATE TABLE aircraft_types_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                code TEXT NOT NULL,
                family TEXT NOT NULL,
                long_name TEXT NOT NULL,
                manufacturer TEXT NULL,
                category TEXT NOT NULL,
                engine_type TEXT NOT NULL,
                mtow INTEGER NOT NULL,
                engine_count INTEGER NOT NULL,
                multi_pilot INTEGER NOT NULL,
                complex INTEGER NOT NULL,
                efis INTEGER NOT NULL,
                high_performance INTEGER NOT NULL,
                is_locked INTEGER NOT NULL,
                CHECK(engine_type IN ('rocket','piston','turboprop','jet','electric','ultralight','drone','glider','airship','balloon','paraplane')),
                CHECK(category IN ('amphibian','gyrocopter','helicopter','landplane','seaplane','tiltwing')),
                CHECK(engine_count BETWEEN 1 AND 9)
              );
            ''');
        await migrator.database.customStatement('''
              INSERT INTO aircraft_types_new (
                id,
                code,
                family,
                long_name,
                manufacturer,
                category,
                engine_type,
                mtow,
                engine_count,
                multi_pilot,
                complex,
                efis,
                high_performance,
                is_locked
              )
              SELECT
                id,
                code,
                family,
                long_name,
                manufacturer,
                category,
                engine_type,
                mtow,
                engine_count,
                multi_pilot,
                complex,
                efis,
                high_performance,
                is_locked
              FROM aircraft_types;
            ''');
        await migrator.database.customStatement('DROP TABLE aircraft_types;');
        await migrator.database.customStatement(
          'ALTER TABLE aircraft_types_new RENAME TO aircraft_types;',
        );
      }
      if (from < 3) {
        await migrator.addColumn(positionings, positionings.isLocked);
      }
      if (from < 4) {
        await migrator.database.customStatement('''
              CREATE TABLE flights_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                aircraft_id INTEGER NOT NULL REFERENCES aircrafts(id),
                departure_airport_id INTEGER NOT NULL REFERENCES airports(id),
                arrival_airport_id INTEGER NOT NULL REFERENCES airports(id),
                departure_date_time_id INTEGER NOT NULL REFERENCES time_lines(id),
                take_off_date_time INTEGER NULL,
                landing_date_time INTEGER NULL,
                arrival_date_time INTEGER NULL,
                time_pic_minutes INTEGER NOT NULL,
                time_picus_minutes INTEGER NOT NULL,
                time_sic_minutes INTEGER NOT NULL,
                time_dual_minutes INTEGER NOT NULL,
                time_instructor_minutes INTEGER NOT NULL,
                time_ifr_minutes INTEGER NOT NULL,
                time_instrument_minutes INTEGER NOT NULL,
                time_simulated_instrument_minutes INTEGER NOT NULL,
                time_night_minutes INTEGER NOT NULL,
                time_cross_country_minutes INTEGER NOT NULL,
                time_custom1_minutes INTEGER NOT NULL,
                time_custom2_minutes INTEGER NOT NULL,
                time_custom3_minutes INTEGER NOT NULL,
                time_custom4_minutes INTEGER NOT NULL,
                time_flight_minutes INTEGER NOT NULL,
                time_block_minutes INTEGER NOT NULL,
                distance_n_m INTEGER NOT NULL,
                ifr_approaches INTEGER NOT NULL,
                take_offs_days INTEGER NOT NULL,
                take_offs_night INTEGER NOT NULL,
                landings_day INTEGER NOT NULL,
                landings_night INTEGER NOT NULL,
                approach_type TEXT NOT NULL,
                remarks TEXT NOT NULL,
                notes TEXT NOT NULL,
                is_locked INTEGER NOT NULL,
                signature_image BLOB NULL
              );
            ''');
        await migrator.database.customStatement('''
              INSERT INTO flights_new (
                id,
                aircraft_id,
                departure_airport_id,
                arrival_airport_id,
                departure_date_time_id,
                take_off_date_time,
                landing_date_time,
                arrival_date_time,
                time_pic_minutes,
                time_picus_minutes,
                time_sic_minutes,
                time_dual_minutes,
                time_instructor_minutes,
                time_ifr_minutes,
                time_instrument_minutes,
                time_simulated_instrument_minutes,
                time_night_minutes,
                time_cross_country_minutes,
                time_custom1_minutes,
                time_custom2_minutes,
                time_custom3_minutes,
                time_custom4_minutes,
                time_flight_minutes,
                time_block_minutes,
                distance_n_m,
                ifr_approaches,
                take_offs_days,
                take_offs_night,
                landings_day,
                landings_night,
                approach_type,
                remarks,
                notes,
                is_locked,
                signature_image
              )
              SELECT
                id,
                aircraft_id,
                departure_airport_id,
                arrival_airport_id,
                departure_date_time_id,
                take_off_date_time,
                landing_date_time,
                arrival_date_time,
                time_pic_minutes,
                time_picus_minutes,
                time_sic_minutes,
                time_dual_minutes,
                time_instructor_minutes,
                time_ifr_minutes,
                time_instrument_minutes,
                time_simulated_instrument_minutes,
                time_night_minutes,
                time_cross_country_minutes,
                time_custom1_minutes,
                time_custom2_minutes,
                time_custom3_minutes,
                time_custom4_minutes,
                time_flight_minutes,
                time_block_minutes,
                distance_n_m,
                ifr_approaches,
                take_offs_days,
                take_offs_night,
                landings_day,
                landings_night,
                approach_type,
                remarks,
                notes,
                is_locked,
                signature_image
              FROM flights;
            ''');
        await migrator.database.customStatement('DROP TABLE flights;');
        await migrator.database.customStatement(
          'ALTER TABLE flights_new RENAME TO flights;',
        );
      }
      if (from < 5) {
        await migrator.database.customStatement('''
              CREATE TABLE simulator_trainings_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                aircraft_id INTEGER NOT NULL REFERENCES aircrafts(id),
                start_time_line_id INTEGER NOT NULL REFERENCES time_lines(id),
                end_date_time INTEGER NULL,
                time_total INTEGER NOT NULL,
                remarks TEXT NOT NULL,
                notes TEXT NOT NULL,
                is_locked INTEGER NOT NULL,
                signature_image BLOB NULL
              );
            ''');
        await migrator.database.customStatement('''
              INSERT INTO simulator_trainings_new (
                id,
                aircraft_id,
                start_time_line_id,
                end_date_time,
                time_total,
                remarks,
                notes,
                is_locked,
                signature_image
              )
              SELECT
                id,
                aircraft_id,
                start_time_line_id,
                end_date_time,
                time_total,
                remarks,
                notes,
                is_locked,
                signature_image
              FROM simulator_trainings;
            ''');
        await migrator.database.customStatement(
          'DROP TABLE simulator_trainings;',
        );
        await migrator.database.customStatement(
          'ALTER TABLE simulator_trainings_new RENAME TO simulator_trainings;',
        );

        await migrator.database.customStatement('''
              CREATE TABLE positionings_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                departure_place_id INTEGER NOT NULL REFERENCES airports(id),
                arrival_place_id INTEGER NOT NULL REFERENCES airports(id),
                departure_date_time_id INTEGER NOT NULL REFERENCES time_lines(id),
                arrival_date_time INTEGER NULL,
                time_total_minutes INTEGER NOT NULL,
                is_locked INTEGER NOT NULL
              );
            ''');
        await migrator.database.customStatement('''
              INSERT INTO positionings_new (
                id,
                departure_place_id,
                arrival_place_id,
                departure_date_time_id,
                arrival_date_time,
                time_total_minutes,
                is_locked
              )
              SELECT
                id,
                departure_place_id,
                arrival_place_id,
                departure_date_time_id,
                arrival_date_time,
                time_total_minutes,
                is_locked
              FROM positionings;
            ''');
        await migrator.database.customStatement('DROP TABLE positionings;');
        await migrator.database.customStatement(
          'ALTER TABLE positionings_new RENAME TO positionings;',
        );
      }
      if (from < 6) {
        await migrator.addColumn(aircrafts, aircrafts.notes);
      }
      if (from < 7) {
        await migrator.addColumn(positionings, positionings.notes);
      }
      if (from < 8) {
        await migrator.database.customStatement('''
              CREATE TABLE aircrafts_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                aircraft_type_id INTEGER NOT NULL REFERENCES aircraft_types(id),
                registration TEXT NOT NULL,
                mtow INTEGER NULL,
                is_simulator INTEGER NOT NULL,
                is_favorite INTEGER NOT NULL,
                is_locked INTEGER NOT NULL,
                notes TEXT NULL,
                CHECK ("is_simulator" IN (0, 1)),
                CHECK ("is_favorite" IN (0, 1)),
                CHECK ("is_locked" IN (0, 1))
              );
            ''');
        await migrator.database.customStatement('''
              INSERT INTO aircrafts_new (
                id,
                aircraft_type_id,
                registration,
                mtow,
                is_simulator,
                is_favorite,
                is_locked,
                notes
              )
              SELECT
                id,
                aircraft_type_id,
                registration,
                mtow,
                is_simulator,
                is_favorite,
                is_locked,
                notes
              FROM aircrafts;
            ''');
        await migrator.database.customStatement('DROP TABLE aircrafts;');
        await migrator.database.customStatement(
          'ALTER TABLE aircrafts_new RENAME TO aircrafts;',
        );
      }
      if (from < 9) {
        await migrator.createTable(limitRules);
        await migrator.createTable(ruleSnapshots);
        await migrator.addColumn(dutyPeriods, dutyPeriods.restBeforeMinutes);
      }
      if (from < 10) {
        await migrator.database.customStatement('''
              CREATE TABLE limit_rules_new (
                rule_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                rule_name TEXT NOT NULL,
                metric TEXT NOT NULL,
                rule_type TEXT NOT NULL,
                window_type TEXT NOT NULL,
                window_value INTEGER NOT NULL,
                limit_value REAL NOT NULL,
                limit_unit TEXT NOT NULL,
                warn_yellow_before REAL NOT NULL DEFAULT 0,
                warn_red_before REAL NOT NULL DEFAULT 0,
                warn_yellow_color TEXT NOT NULL DEFAULT '#FFC107',
                warn_red_color TEXT NOT NULL DEFAULT '#DC3545',
                active INTEGER NOT NULL DEFAULT 1,
                notes TEXT NULL
              );
            ''');
        await migrator.database.customStatement('''
              INSERT INTO limit_rules_new (
                rule_id,
                rule_name,
                metric,
                rule_type,
                window_type,
                window_value,
                limit_value,
                limit_unit,
                warn_yellow_before,
                warn_red_before,
                warn_yellow_color,
                warn_red_color,
                active,
                notes
              )
              SELECT
                rule_id,
                rule_name,
                metric,
                rule_type,
                window_type,
                window_value,
                limit_value,
                limit_unit,
                warn_yellow_before,
                warn_red_before,
                warn_yellow_color,
                warn_red_color,
                active,
                notes
              FROM limit_rules;
            ''');
        await migrator.database.customStatement('DROP TABLE rule_snapshots;');
        await migrator.database.customStatement('DROP TABLE limit_rules;');
        await migrator.database.customStatement(
          'ALTER TABLE limit_rules_new RENAME TO limit_rules;',
        );
        await migrator.createTable(ruleSnapshots);
        await migrator.database.customStatement('DROP TABLE IF EXISTS pilots;');
      }
      if (from < 11) {
        await migrator.createTable(previousExperiences);
      }
      if (from < 12) {
        await migrator.database.customStatement('''
              CREATE TABLE previous_experiences_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                aircraft_type_id INTEGER NOT NULL REFERENCES aircraft_types(id),
                date_time_first_flight INTEGER NULL,
                date_time_last_flight INTEGER NULL,
                time_p_i_c_minutes INTEGER NOT NULL,
                time_p_i_c_u_s_minutes INTEGER NOT NULL,
                time_s_i_c_minutes INTEGER NOT NULL,
                time_dual_minutes INTEGER NOT NULL,
                time_instructor_minutes INTEGER NOT NULL,
                time_i_f_r_minutes INTEGER NOT NULL,
                time_instrument_minutes INTEGER NOT NULL,
                time_simulated_instrument_minutes INTEGER NOT NULL,
                time_night_minutes INTEGER NOT NULL,
                time_cross_country_minutes INTEGER NOT NULL,
                time_custom1_minutes INTEGER NOT NULL,
                time_custom2_minutes INTEGER NOT NULL,
                time_custom3_minutes INTEGER NOT NULL,
                time_custom4_minutes INTEGER NOT NULL,
                time_flight_minutes INTEGER NOT NULL,
                time_block_minutes INTEGER NOT NULL,
                time_simulator_minutes INTEGER NOT NULL,
                distance_n_m INTEGER NOT NULL,
                ifr_approaches INTEGER NOT NULL,
                take_offs_days INTEGER NOT NULL,
                take_offs_night INTEGER NOT NULL,
                landings_day INTEGER NOT NULL,
                landings_night INTEGER NOT NULL
              );
            ''');
        await migrator.database.customStatement('''
              INSERT INTO previous_experiences_new (
                id,
                aircraft_type_id,
                date_time_first_flight,
                date_time_last_flight,
                time_p_i_c_minutes,
                time_p_i_c_u_s_minutes,
                time_s_i_c_minutes,
                time_dual_minutes,
                time_instructor_minutes,
                time_i_f_r_minutes,
                time_instrument_minutes,
                time_simulated_instrument_minutes,
                time_night_minutes,
                time_cross_country_minutes,
                time_custom1_minutes,
                time_custom2_minutes,
                time_custom3_minutes,
                time_custom4_minutes,
                time_flight_minutes,
                time_block_minutes,
                time_simulator_minutes,
                distance_n_m,
                ifr_approaches,
                take_offs_days,
                take_offs_night,
                landings_day,
                landings_night
              )
              SELECT
                id,
                aircraft_type_id,
                date_time_first_flight,
                date_time_last_flight,
                time_p_i_c_minutes,
                time_p_i_c_u_s_minutes,
                time_s_i_c_minutes,
                time_dual_minutes,
                time_instructor_minutes,
                time_i_f_r_minutes,
                time_instrument_minutes,
                time_simulated_instrument_minutes,
                time_night_minutes,
                time_cross_country_minutes,
                time_custom1_minutes,
                time_custom2_minutes,
                time_custom3_minutes,
                time_custom4_minutes,
                time_flight_minutes,
                time_block_minutes,
                time_simulator_minutes,
                distance_n_m,
                ifr_approaches,
                take_offs_days,
                take_offs_night,
                landings_day,
                landings_night
              FROM previous_experiences;
            ''');
        await migrator.database.customStatement(
          'DROP TABLE previous_experiences;',
        );
        await migrator.database.customStatement(
          'ALTER TABLE previous_experiences_new '
          'RENAME TO previous_experiences;',
        );
      }
      if (from < 13) {
        await migrator.addColumn(flights, flights.timeTotalBlockMinutes);
        await migrator.addColumn(flights, flights.pilotFunction);
        await migrator.database.customStatement('''
              UPDATE flights
              SET
                time_total_block_minutes = time_block_minutes,
                pilot_function = CASE
                  WHEN UPPER(TRIM(approach_type)) IN ('PF', 'PNF', 'PF/PNF', 'PNF/PF', 'IRP 3', 'IRP 4')
                    THEN UPPER(TRIM(approach_type))
                  WHEN (take_offs_days + take_offs_night) > 0 AND (landings_day + landings_night) > 0
                    THEN 'PF'
                  WHEN (take_offs_days + take_offs_night) > 0 AND (landings_day + landings_night) = 0
                    THEN 'PF/PNF'
                  WHEN (take_offs_days + take_offs_night) = 0 AND (landings_day + landings_night) > 0
                    THEN 'PNF/PF'
                  ELSE 'PNF'
                END;
            ''');
      }
      if (from < 14) {
        await migrator.database.customStatement('''
              CREATE TABLE flight_crew_assignments_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                flight_id INTEGER NOT NULL REFERENCES flights(id),
                crew_id INTEGER NOT NULL REFERENCES crew(id),
                position TEXT NOT NULL,
                CHECK(position IN ('pic','picus','sic','trainee','instructor','observer','relief','relief_captain','relief_first_officer','cabin_senior','cabin_crew','other'))
              );
            ''');
        await migrator.database.customStatement('''
              INSERT INTO flight_crew_assignments_new (
                id,
                flight_id,
                crew_id,
                position
              )
              SELECT
                id,
                flight_id,
                crew_id,
                position
              FROM flight_crew_assignments;
            ''');
        await migrator.database.customStatement(
          'DROP TABLE flight_crew_assignments;',
        );
        await migrator.database.customStatement(
          'ALTER TABLE flight_crew_assignments_new '
          'RENAME TO flight_crew_assignments;',
        );

        await migrator.database.customStatement('''
              CREATE TABLE simulator_crew_assignments_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                simulator_id INTEGER NOT NULL REFERENCES simulator_trainings(id),
                crew_id INTEGER NOT NULL REFERENCES crew(id),
                position TEXT NOT NULL,
                CHECK(position IN ('pic','picus','sic','trainee','instructor','observer','relief','relief_captain','relief_first_officer','cabin_senior','cabin_crew','other'))
              );
            ''');
        await migrator.database.customStatement('''
              INSERT INTO simulator_crew_assignments_new (
                id,
                simulator_id,
                crew_id,
                position
              )
              SELECT
                id,
                simulator_id,
                crew_id,
                position
              FROM simulator_crew_assignments;
            ''');
        await migrator.database.customStatement(
          'DROP TABLE simulator_crew_assignments;',
        );
        await migrator.database.customStatement(
          'ALTER TABLE simulator_crew_assignments_new '
          'RENAME TO simulator_crew_assignments;',
        );
      }
      if (from < 15) {
        await migrator.addColumn(
          previousExperiences,
          previousExperiences.flightCount,
        );
      }
    },

    /// Public API documentation.
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

      /// Public API documentation.
    });
  }

  /// Public API documentation.
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
