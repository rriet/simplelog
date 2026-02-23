import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/aircraft_types_table.dart';

/// Public API documentation.
class PreviousExperiences extends Table {
  /// Public API documentation.
  IntColumn get id => integer().autoIncrement()();
  /// Public API documentation.
  IntColumn get aircraftTypeId => integer().references(AircraftTypes, #id)();
  /// Public API documentation.
  DateTimeColumn get dateTimeFirstFlight => dateTime().nullable()();
  /// Public API documentation.
  DateTimeColumn get dateTimeLastFlight => dateTime().nullable()();
  /// Public API documentation.
  IntColumn get timePICMinutes => integer()();
  /// Public API documentation.
  IntColumn get timePICUSMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeSICMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeDualMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeInstructorMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeIFRMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeInstrumentMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeSimulatedInstrumentMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeNightMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeCrossCountryMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeCustom1Minutes => integer()();
  /// Public API documentation.
  IntColumn get timeCustom2Minutes => integer()();
  /// Public API documentation.
  IntColumn get timeCustom3Minutes => integer()();
  /// Public API documentation.
  IntColumn get timeCustom4Minutes => integer()();
  /// Public API documentation.
  IntColumn get timeFlightMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeBlockMinutes => integer()();
  /// Public API documentation.
  IntColumn get timeSimulatorMinutes => integer()();
  /// Public API documentation.
  IntColumn get distanceNM => integer()();
  /// Public API documentation.
  IntColumn get ifrApproaches => integer()();
  /// Public API documentation.
  IntColumn get takeOffsDays => integer()();
  /// Public API documentation.
  IntColumn get takeOffsNight => integer()();
  /// Public API documentation.
  IntColumn get landingsDay => integer()();
  /// Public API documentation.
  IntColumn get landingsNight => integer()();
}
