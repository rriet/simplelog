import 'package:drift/drift.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';

/// Public API documentation.
class EngineTypeConverter extends TypeConverter<EngineType, String> {
  /// Public API documentation.
  const EngineTypeConverter();

  @override
  EngineType fromSql(String fromDb) {
    return switch (fromDb) {
      'rocket' => EngineType.rocket,
      'piston' => EngineType.piston,
      'turboprop' => EngineType.turboprop,
      'jet' => EngineType.jet,
      'electric' => EngineType.electric,
      'ultralight' => EngineType.ultraLightAircraft,
      'drone' => EngineType.drone,
      'glider' => EngineType.glider,
      'airship' => EngineType.airship,
      'balloon' => EngineType.balloon,
      'paraplane' => EngineType.paraplane,
      _ => EngineType.unknown,
    };
  }

  @override
  String toSql(EngineType value) {
    return switch (value) {
      EngineType.rocket => 'rocket',
      EngineType.piston => 'piston',
      EngineType.turboprop => 'turboprop',
      EngineType.jet => 'jet',
      EngineType.electric => 'electric',
      EngineType.ultraLightAircraft => 'ultralight',
      EngineType.drone => 'drone',
      EngineType.glider => 'glider',
      EngineType.airship => 'airship',
      EngineType.balloon => 'balloon',
      EngineType.paraplane => 'paraplane',
      EngineType.unknown => throw ArgumentError(
        'Cannot save unknown EngineType to database',
      ),
    };
  }
}
