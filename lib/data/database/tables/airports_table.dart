import 'package:drift/drift.dart';

class Airports extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get icao => text()();
  TextColumn get iata => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get country => text().nullable()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  BoolColumn get isFavorite => boolean()();
  BoolColumn get isLocked => boolean()();

  @override
  List<String> get customConstraints => const [
        'UNIQUE(icao)',
      ];
}
