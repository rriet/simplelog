import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/aircraft_types_table.dart';

/// Imported/manual totals representing experience before in-app records.
class PreviousExperiences extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Aircraft type these totals apply to.
  IntColumn get aircraftTypeId => integer().references(
    AircraftTypes,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();

  /// Earliest known flight date for this experience bucket.
  DateTimeColumn get dateTimeFirstFlight => dateTime().nullable()();

  /// Most recent known flight date for this experience bucket.
  DateTimeColumn get dateTimeLastFlight => dateTime().nullable()();

  /// PIC minutes.
  IntColumn get timePICMinutes => integer()();

  /// PICUS minutes.
  IntColumn get timePICUSMinutes => integer()();

  /// SIC minutes.
  IntColumn get timeSICMinutes => integer()();

  /// Dual minutes.
  IntColumn get timeDualMinutes => integer()();

  /// Instructor minutes.
  IntColumn get timeInstructorMinutes => integer()();

  /// IFR minutes.
  IntColumn get timeIFRMinutes => integer()();

  /// Instrument minutes.
  IntColumn get timeInstrumentMinutes => integer()();

  /// Simulated instrument minutes.
  IntColumn get timeSimulatedInstrumentMinutes => integer()();

  /// Night minutes.
  IntColumn get timeNightMinutes => integer()();

  /// Cross-country minutes.
  IntColumn get timeCrossCountryMinutes => integer()();

  /// Custom time bucket 1 minutes.
  IntColumn get timeCustom1Minutes => integer()();

  /// Custom time bucket 2 minutes.
  IntColumn get timeCustom2Minutes => integer()();

  /// Custom time bucket 3 minutes.
  IntColumn get timeCustom3Minutes => integer()();

  /// Custom time bucket 4 minutes.
  IntColumn get timeCustom4Minutes => integer()();

  /// Flight minutes.
  IntColumn get timeFlightMinutes => integer()();

  /// Block minutes.
  IntColumn get timeBlockMinutes => integer()();

  /// Simulator minutes.
  IntColumn get timeSimulatorMinutes => integer()();

  /// Distance in nautical miles.
  IntColumn get distanceNM => integer()();

  /// Number of flights/sectors represented.
  IntColumn get flightCount => integer().withDefault(const Constant(0))();

  /// IFR approaches count.
  IntColumn get ifrApproaches => integer()();

  /// Day takeoffs count.
  IntColumn get takeOffsDays => integer()();

  /// Night takeoffs count.
  IntColumn get takeOffsNight => integer()();

  /// Day landings count.
  IntColumn get landingsDay => integer()();

  /// Night landings count.
  IntColumn get landingsNight => integer()();
}
