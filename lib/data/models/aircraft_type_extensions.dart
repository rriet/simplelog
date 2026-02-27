import 'package:simplelog/data/database/app_database.dart';

/// Convenience getters for [AircraftType] domain-derived properties.
extension AircraftTypeExtensions on AircraftType {
  /// True when the aircraft type declares more than one engine.
  bool get isMultiEngine => engineCount > 1;
}
