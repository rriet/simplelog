import 'package:drift/drift.dart';

import 'package:simplelog/data/database/tables/aircrafts_table.dart';
import 'package:simplelog/data/database/tables/airports_table.dart';
import 'package:simplelog/data/database/tables/timeline_table.dart';

/// Main flight log table.
class Flights extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Linked aircraft id.
  IntColumn get aircraftId => integer().references(Aircrafts, #id)();

  /// Departure airport id.
  IntColumn get departureAirportId => integer().references(Airports, #id)();

  /// Arrival airport id.
  IntColumn get arrivalAirportId => integer().references(Airports, #id)();

  /// Timeline id for departure/chocks-off event.
  IntColumn get departureDateTimeId => integer().references(TimeLines, #id)();

  /// Optional takeoff timestamp.
  DateTimeColumn get takeOffDateTime => dateTime().nullable()();

  /// Optional landing timestamp.
  DateTimeColumn get landingDateTime => dateTime().nullable()();

  /// Optional arrival/chocks-on timestamp.
  DateTimeColumn get arrivalDateTime => dateTime().nullable()();

  /// PIC time in minutes.
  IntColumn get timePICMinutes => integer()();

  /// PICUS time in minutes.
  IntColumn get timePICUSMinutes => integer()();

  /// SIC time in minutes.
  IntColumn get timeSICMinutes => integer()();

  /// Dual time in minutes.
  IntColumn get timeDualMinutes => integer()();

  /// Instructor time in minutes.
  IntColumn get timeInstructorMinutes => integer()();

  /// IFR time in minutes.
  IntColumn get timeIFRMinutes => integer()();

  /// Instrument time in minutes.
  IntColumn get timeInstrumentMinutes => integer()();

  /// Simulated instrument time in minutes.
  IntColumn get timeSimulatedInstrumentMinutes => integer()();

  /// Night time in minutes.
  IntColumn get timeNightMinutes => integer()();

  /// Cross-country time in minutes.
  IntColumn get timeCrossCountryMinutes => integer()();

  /// Custom time bucket 1 in minutes.
  IntColumn get timeCustom1Minutes => integer()();

  /// Custom time bucket 2 in minutes.
  IntColumn get timeCustom2Minutes => integer()();

  /// Custom time bucket 3 in minutes.
  IntColumn get timeCustom3Minutes => integer()();

  /// Custom time bucket 4 in minutes.
  IntColumn get timeCustom4Minutes => integer()();

  /// Airborne/flight time in minutes.
  IntColumn get timeFlightMinutes => integer()();

  /// Block time in minutes.
  IntColumn get timeBlockMinutes => integer()();

  /// Accumulated total block time in minutes.
  IntColumn get timeTotalBlockMinutes =>
      integer().withDefault(const Constant(0))();

  /// Great-circle distance in nautical miles.
  IntColumn get distanceNM => integer()();

  /// Number of IFR approaches.
  IntColumn get ifrApproaches => integer()();

  /// Day takeoffs count.
  IntColumn get takeOffsDays => integer()();

  /// Night takeoffs count.
  IntColumn get takeOffsNight => integer()();

  /// Day landings count.
  IntColumn get landingsDay => integer()();

  /// Night landings count.
  IntColumn get landingsNight => integer()();

  /// Pilot function label (e.g. PF/PNF/IRP3/IRP4).
  TextColumn get pilotFunction => text().withDefault(const Constant('PF'))();

  /// Free-text approach type summary.
  TextColumn get approachType => text()();

  /// User remarks.
  TextColumn get remarks => text()();

  /// Private notes.
  TextColumn get notes => text()();

  /// Lock flag to prevent editing.
  BoolColumn get isLocked => boolean()();

  /// Optional endorsement/signature image bytes.
  BlobColumn get signatureImage => blob().nullable()();

  /// Optional serialized endorsement metadata.
  TextColumn get endorsementData => text().nullable()();

  /// Hash used to verify endorsement integrity.
  TextColumn get endorsementHash => text().nullable()();
}
