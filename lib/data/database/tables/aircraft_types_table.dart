import 'package:drift/drift.dart';

import 'package:simplelog/data/database/converters/aircraft_category_converter.dart';
import 'package:simplelog/data/database/converters/engine_type_converter.dart';

const String _engineTypeConstraint =
    "CHECK(engine_type IN ('rocket','piston','turboprop','jet','electric', "
    "'ultralight','drone','glider','airship','balloon','paraplane'))";
const String _categoryConstraint =
    "CHECK(category IN ('amphibian','gyrocopter','helicopter','landplane', "
    "'seaplane','tiltwing'))";

/// Aircraft type catalog table.
class AircraftTypes extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();
  /// Short type code (e.g. A320).
  TextColumn get code => text()();
  /// Family/group label.
  TextColumn get family => text()();
  /// Human-readable long type name.
  TextColumn get longName => text()();
  /// Optional manufacturer name.
  TextColumn get manufacturer => text().nullable()();
  /// Aircraft category enum stored via converter.
  TextColumn get category => text().map(const AircraftCategoryConverter())();
  /// Engine type enum stored via converter.
  TextColumn get engineType => text().map(const EngineTypeConverter())();
  /// Maximum takeoff weight.
  IntColumn get mtow => integer()();
  /// Engine count.
  IntColumn get engineCount => integer()();
  /// Whether type requires multi-pilot operation.
  BoolColumn get multiPilot => boolean()();
  /// Whether aircraft is complex.
  BoolColumn get complex => boolean()();
  /// Whether cockpit is EFIS-equipped.
  BoolColumn get efis => boolean()();
  /// Whether aircraft is high performance.
  BoolColumn get highPerformance => boolean()();
  /// Lock flag preventing edits.
  BoolColumn get isLocked => boolean()();

  @override
  List<String> get customConstraints => const [
    _engineTypeConstraint,
    _categoryConstraint,
    'CHECK(engine_count BETWEEN 1 AND 9)',
  ];
}
