import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'enums/aircraft_category.dart';
import 'enums/crew_position.dart';
import 'enums/engine_type.dart';
import 'converters/aircraft_category_converter.dart';
import 'converters/crew_position_converter.dart';
import 'converters/engine_type_converter.dart';
import 'tables/aircrafts_table.dart';
import 'tables/aircraft_types_table.dart';
import 'tables/airports_table.dart';
import 'tables/crew_table.dart';
import 'tables/duty_periods_table.dart';
import 'tables/flight_crew_assignments_table.dart';
import 'tables/flights_table.dart';
import 'tables/positionings_table.dart';
import 'tables/simulator_crew_assignments_table.dart';
import 'tables/simulator_trainings_table.dart';
import 'tables/timeline_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    AircraftTypes,
    Aircrafts,
    Airports,
    Flights,
    Positionings,
    DutyPeriods,
    Crew,
    FlightCrewAssignments,
    SimulatorCrewAssignments,
    SimulatorTrainings,
    TimeLines,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'simplelog'));

  @override
  int get schemaVersion => 6;

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
            await migrator.database.customStatement(
              'DROP TABLE aircraft_types;',
            );
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
            await migrator.database.customStatement(
              'DROP TABLE positionings;',
            );
            await migrator.database.customStatement(
              'ALTER TABLE positionings_new RENAME TO positionings;',
            );
          }
          if (from < 6) {
            await migrator.addColumn(aircrafts, aircrafts.notes);
          }
        },
      );

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(flightCrewAssignments).go();
      await delete(simulatorCrewAssignments).go();
      await delete(flights).go();
      await delete(simulatorTrainings).go();
      await delete(positionings).go();
      await delete(dutyPeriods).go();
      await delete(timeLines).go();
      await delete(aircrafts).go();
      await delete(aircraftTypes).go();
      await delete(airports).go();
      await delete(crew).go();
    });
  }

  Future<void> assertTimelineUniqueness(int timeLineId) async {
    final results = await Future.wait([
      _countByTimelineId(
        flights,
        flights.departureDateTimeId,
        timeLineId,
      ),
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

    final total = flightCount +
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
    final query = selectOnly(table)..addColumns([countExpression]);
    query.where(column.equals(timeLineId));
    final row = await query.getSingle();
    return row.read(countExpression) ?? 0;
  }
}
