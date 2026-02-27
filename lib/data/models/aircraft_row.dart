import 'package:simplelog/data/database/app_database.dart';

/// Aircraft row paired with optional aircraft type details.
class AircraftRow {
  /// Creates an aircraft row wrapper.
  const AircraftRow(this.aircraft, this.type);

  /// Aircraft entity.
  final Aircraft aircraft;
  /// Related aircraft type (if available).
  final AircraftType? type;

  /// Convenience id getter.
  int get id => aircraft.id;
  /// Convenience registration getter.
  String get registration => aircraft.registration;
  /// Convenience favorite getter.
  bool get isFavorite => aircraft.isFavorite;
  /// Convenience lock getter.
  bool get isLocked => aircraft.isLocked;
  /// MTOW preferring aircraft override then type default.
  int get effectiveMtow => aircraft.mtow ?? type?.mtow ?? 0;
}
