import 'package:simplelog/data/database/app_database.dart';

/// Airport row enriched with usage counters.
class AirportRow {
  /// Creates an enriched airport row.
  const AirportRow(
    this.airport, {
    required this.flightCount,
    required this.positioningCount,
    required this.takeoffCount,
    required this.landingCount,
  });

  /// Airport entity.
  final Airport airport;
  /// Number of flights referencing this airport.
  final int flightCount;
  /// Number of positionings referencing this airport.
  final int positioningCount;
  /// Total takeoffs at this airport.
  final int takeoffCount;
  /// Total landings at this airport.
  final int landingCount;

  /// Convenience id getter.
  int get id => airport.id;
  /// Convenience ICAO getter.
  String get icao => airport.icao;
  /// Convenience favorite getter.
  bool get isFavorite => airport.isFavorite;
  /// Convenience lock getter.
  bool get isLocked => airport.isLocked;
  /// Combined flight + positioning count.
  int get totalVisits => flightCount + positioningCount;
}
