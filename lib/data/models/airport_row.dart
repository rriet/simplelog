import 'package:simplelog/data/database/app_database.dart';

class AirportRow {
  const AirportRow(
    this.airport, {
    required this.flightCount,
    required this.positioningCount,
    required this.takeoffCount,
    required this.landingCount,
  });

  final Airport airport;
  final int flightCount;
  final int positioningCount;
  final int takeoffCount;
  final int landingCount;

  int get id => airport.id;
  String get icao => airport.icao;
  bool get isFavorite => airport.isFavorite;
  bool get isLocked => airport.isLocked;
  int get totalVisits => flightCount + positioningCount;
}
