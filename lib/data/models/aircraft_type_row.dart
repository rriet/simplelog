import 'package:simplelog/data/database/app_database.dart';

/// Aircraft type row wrapper used by list/filter UIs.
class AircraftTypeRow {
  /// Creates an aircraft type wrapper.
  const AircraftTypeRow(this.type);

  /// Backing aircraft type entity.
  final AircraftType type;

  /// Convenience id getter.
  int get id => type.id;
  /// Convenience code getter.
  String get code => type.code;
  /// Convenience family getter.
  String get family => type.family;
  /// Convenience long-name getter.
  String get longName => type.longName;
  /// Convenience manufacturer getter.
  String? get manufacturer => type.manufacturer;
  /// Convenience lock getter.
  bool get isLocked => type.isLocked;
}
