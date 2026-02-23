import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
extension AircraftTypeExtensions on AircraftType {
  /// Public API documentation.
  bool get isMultiEngine => engineCount > 1;
}
