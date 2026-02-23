import 'package:simplelog/data/database/app_database.dart';

/// Public API documentation.
class AirportRow {
  /// Public API documentation.
  const AirportRow(
    this.airport, {
    required this.flightCount,
    required this.positioningCount,
    required this.takeoffCount,
    required this.landingCount,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final Airport airport;
  /// Public API documentation.
  final int flightCount;
  /// Public API documentation.
  final int positioningCount;
  /// Public API documentation.
  final int takeoffCount;
  /// Public API documentation.
  final int landingCount;

  /// Public API documentation.
  int get id => airport.id;
  /// Public API documentation.
  String get icao => airport.icao;
  /// Public API documentation.
  bool get isFavorite => airport.isFavorite;
  /// Public API documentation.
  bool get isLocked => airport.isLocked;
  /// Public API documentation.
  int get totalVisits => flightCount + positioningCount;
}
