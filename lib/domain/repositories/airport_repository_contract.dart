import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';

abstract class AirportRepositoryContract {
  Stream<List<AirportRow>> watchAirports(
    String query,
    AirportFilters filters,
  );

  Future<void> toggleLock(Airport item);
  Future<void> toggleFavorite(Airport item);
  Future<void> delete(Airport item);
  Future<int> create(AirportsCompanion companion);
  Future<void> update(Airport item);
  Future<int> countDuplicateIcao(String icao, int currentId);
  Future<int> countFlightsUsingAirport(int airportId);
  Future<int> countPositioningsUsingAirport(int airportId);
}
