import 'package:drift/drift.dart';

/// Airport master-data table used by flights, sims and filters.
class Airports extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();

  /// ICAO airport code.
  TextColumn get icao => text()();

  /// Optional IATA airport code.
  TextColumn get iata => text().nullable()();

  /// Optional airport display name.
  TextColumn get name => text().nullable()();

  /// Optional city.
  TextColumn get city => text().nullable()();

  /// Optional country.
  TextColumn get country => text().nullable()();

  /// Latitude in decimal degrees.
  RealColumn get latitude => real()();

  /// Longitude in decimal degrees.
  RealColumn get longitude => real()();

  /// Whether airport is pinned by user.
  BoolColumn get isFavorite => boolean()();

  /// Whether row is protected from edits.
  BoolColumn get isLocked => boolean()();

  @override
  List<String> get customConstraints => const ['UNIQUE(icao)'];
}
