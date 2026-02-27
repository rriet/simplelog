import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';

/// Contract for airport CRUD plus usage checks.
abstract class AirportRepositoryContract {
  /// Streams airports filtered by text [query] and structured [filters].
  Stream<List<AirportRow>> watchAirports(String query, AirportFilters filters);

  /// Toggles lock state of [item].
  Future<void> toggleLock(Airport item);

  /// Toggles favorite state of [item].
  Future<void> toggleFavorite(Airport item);

  /// Deletes [item].
  Future<void> delete(Airport item);

  /// Inserts a new airport and returns its generated id.
  Future<int> create(AirportsCompanion companion);

  /// Updates an existing airport row.
  Future<void> update(Airport item);

  /// Counts duplicate ICAO rows excluding [currentId].
  Future<int> countDuplicateIcao(String icao, int currentId);

  /// Counts flights that reference [airportId].
  Future<int> countFlightsUsingAirport(int airportId);

  /// Counts positionings that reference [airportId].
  Future<int> countPositioningsUsingAirport(int airportId);
}
