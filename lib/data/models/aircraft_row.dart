import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
class AircraftRow {
  /// Public API documentation.
  const AircraftRow(this.aircraft, this.type);
/// Public API documentation.

  /// Public API documentation.
  final Aircraft aircraft;
  /// Public API documentation.
  final AircraftType? type;
/// Public API documentation.

  /// Public API documentation.
  int get id => aircraft.id;
  /// Public API documentation.
  String get registration => aircraft.registration;
  /// Public API documentation.
  bool get isFavorite => aircraft.isFavorite;
  /// Public API documentation.
  bool get isLocked => aircraft.isLocked;
  /// Public API documentation.
  int get effectiveMtow => aircraft.mtow ?? type?.mtow ?? 0;
}
