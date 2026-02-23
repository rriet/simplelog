import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';

/// Public API documentation.
abstract class AirportRepositoryContract {
  /// Public API documentation.
  Stream<List<AirportRow>> watchAirports(
    String query,
    AirportFilters filters,
  /// Public API documentation.
  );
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleLock(Airport item);
  /// Public API documentation.
  Future<void> toggleFavorite(Airport item);
  /// Public API documentation.
  Future<void> delete(Airport item);
  /// Public API documentation.
  Future<int> create(AirportsCompanion companion);
  /// Public API documentation.
  Future<void> update(Airport item);
  /// Public API documentation.
  Future<int> countDuplicateIcao(String icao, int currentId);
  /// Public API documentation.
  Future<int> countFlightsUsingAirport(int airportId);
  /// Public API documentation.
  Future<int> countPositioningsUsingAirport(int airportId);
}
