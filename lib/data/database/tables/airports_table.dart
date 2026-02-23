import 'package:drift/drift.dart';

/// Public API documentation.
class Airports extends Table {
  /// Public API documentation.
  IntColumn get id => integer().autoIncrement()();
  /// Public API documentation.
  TextColumn get icao => text()();
  /// Public API documentation.
  TextColumn get iata => text().nullable()();
  /// Public API documentation.
  TextColumn get name => text().nullable()();
  /// Public API documentation.
  TextColumn get city => text().nullable()();
  /// Public API documentation.
  TextColumn get country => text().nullable()();
  /// Public API documentation.
  RealColumn get latitude => real()();
  /// Public API documentation.
  RealColumn get longitude => real()();
  /// Public API documentation.
  BoolColumn get isFavorite => boolean()();
  /// Public API documentation.
  BoolColumn get isLocked => boolean()();

  @override
  List<String> get customConstraints => const [
    'UNIQUE(icao)',
  ];
}
