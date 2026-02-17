import 'package:drift/drift.dart';

import '../converters/aircraft_category_converter.dart';
import '../converters/engine_type_converter.dart';

class AircraftTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text()();
  TextColumn get family => text()();
  TextColumn get longName => text()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get category => text().map(const AircraftCategoryConverter())();
  TextColumn get engineType => text().map(const EngineTypeConverter())();
  IntColumn get mtow => integer()();
  IntColumn get engineCount => integer()();
  BoolColumn get multiPilot => boolean()();
  BoolColumn get complex => boolean()();
  BoolColumn get efis => boolean()();
  BoolColumn get highPerformance => boolean()();
  BoolColumn get isLocked => boolean()();

  @override
  List<String> get customConstraints => const [
        "CHECK(engine_type IN ('rocket','piston','turboprop','jet','electric','ultralight','drone','glider','airship','balloon','paraplane'))",
        "CHECK(category IN ('amphibian','gyrocopter','helicopter','landplane','seaplane','tiltwing'))",
        'CHECK(engine_count BETWEEN 1 AND 9)',
      ];
}
