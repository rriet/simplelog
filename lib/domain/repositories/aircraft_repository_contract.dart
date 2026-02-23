import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';

/// Public API documentation.
abstract class AircraftRepositoryContract {
  /// Public API documentation.
  Stream<List<AircraftRow>> watchAircraft(String query);
  /// Public API documentation.
  Future<List<AircraftRow>> fetchAircraftByType(int aircraftTypeId);
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleLock(Aircraft item);
  /// Public API documentation.
  Future<void> toggleFavorite(Aircraft item);
  /// Public API documentation.
  Future<void> delete(Aircraft item);
  /// Public API documentation.
  Future<int> create(AircraftsCompanion companion);
  /// Public API documentation.
  Future<void> update(Aircraft item);
  /// Public API documentation.
  Future<int> countDuplicateRegistration(String registration, int currentId);
  /// Public API documentation.
  Future<int> countFlightsForAircraft(int aircraftId);
  /// Public API documentation.
  Future<int> countSimSessionsForAircraft(int aircraftId);
}
