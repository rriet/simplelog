import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
class AircraftTypeRow {
  /// Public API documentation.
  const AircraftTypeRow(this.type);

  /// Public API documentation.
  final AircraftType type;
/// Public API documentation.

  /// Public API documentation.
  int get id => type.id;
  /// Public API documentation.
  String get code => type.code;
  /// Public API documentation.
  String get family => type.family;
  /// Public API documentation.
  String get longName => type.longName;
  /// Public API documentation.
  String? get manufacturer => type.manufacturer;
  /// Public API documentation.
  bool get isLocked => type.isLocked;
}
