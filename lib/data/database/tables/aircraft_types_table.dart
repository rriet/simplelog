import 'package:drift/drift.dart';

import 'package:simplelog/data/database/converters/aircraft_category_converter.dart';
import 'package:simplelog/data/database/converters/engine_type_converter.dart';

const String _engineTypeConstraint =
    "CHECK(engine_type IN ('rocket','piston','turboprop','jet','electric', "
    "'ultralight','drone','glider','airship','balloon','paraplane'))";
const String _categoryConstraint =
    "CHECK(category IN ('amphibian','gyrocopter','helicopter','landplane', "
    "'seaplane','tiltwing'))";

/// Public API documentation.
class AircraftTypes extends Table {
  /// Public API documentation.
  IntColumn get id => integer().autoIncrement()();
  /// Public API documentation.
  TextColumn get code => text()();
  /// Public API documentation.
  TextColumn get family => text()();
  /// Public API documentation.
  TextColumn get longName => text()();
  /// Public API documentation.
  TextColumn get manufacturer => text().nullable()();
  /// Public API documentation.
  TextColumn get category => text().map(const AircraftCategoryConverter())();
  /// Public API documentation.
  TextColumn get engineType => text().map(const EngineTypeConverter())();
  /// Public API documentation.
  IntColumn get mtow => integer()();
  /// Public API documentation.
  IntColumn get engineCount => integer()();
  /// Public API documentation.
  BoolColumn get multiPilot => boolean()();
  /// Public API documentation.
  BoolColumn get complex => boolean()();
  /// Public API documentation.
  BoolColumn get efis => boolean()();
  /// Public API documentation.
  BoolColumn get highPerformance => boolean()();
  /// Public API documentation.
  BoolColumn get isLocked => boolean()();

  @override
  List<String> get customConstraints => const [
    _engineTypeConstraint,
    _categoryConstraint,
    'CHECK(engine_count BETWEEN 1 AND 9)',
  ];
}
