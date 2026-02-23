import 'package:drift/drift.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';

/// Public API documentation.
class AircraftCategoryConverter
    /// Public API documentation.
    extends TypeConverter<AircraftCategory, String> {
  /// Public API documentation.
  const AircraftCategoryConverter();

  @override
  AircraftCategory fromSql(String fromDb) {
    return switch (fromDb) {
      'amphibian' => AircraftCategory.amphibian,
      'gyrocopter' => AircraftCategory.gyrocopter,
      'helicopter' => AircraftCategory.helicopter,
      'landplane' => AircraftCategory.landplane,
      'seaplane' => AircraftCategory.seaplane,
      'tiltwing' => AircraftCategory.tiltwing,
      _ => AircraftCategory.unknown,
    };
  }

  @override
  String toSql(AircraftCategory value) {
    return switch (value) {
      AircraftCategory.amphibian => 'amphibian',
      AircraftCategory.gyrocopter => 'gyrocopter',
      AircraftCategory.helicopter => 'helicopter',
      AircraftCategory.landplane => 'landplane',
      AircraftCategory.seaplane => 'seaplane',
      AircraftCategory.tiltwing => 'tiltwing',
      AircraftCategory.unknown => throw ArgumentError(
        'Cannot save unknown AircraftCategory to database',
      ),
    };
  }
}
