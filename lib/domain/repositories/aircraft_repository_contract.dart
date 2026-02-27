import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';

/// Contract for aircraft persistence and read models used by the app.
abstract class AircraftRepositoryContract {
  /// Streams aircraft rows filtered by free-text [query].
  Stream<List<AircraftRow>> watchAircraft(String query);

  /// Returns all aircraft assigned to [aircraftTypeId].
  Future<List<AircraftRow>> fetchAircraftByType(int aircraftTypeId);

  /// Toggles the lock status of [item].
  Future<void> toggleLock(Aircraft item);

  /// Toggles the favorite status of [item].
  Future<void> toggleFavorite(Aircraft item);

  /// Deletes [item] from storage.
  Future<void> delete(Aircraft item);

  /// Inserts a new aircraft and returns its generated id.
  Future<int> create(AircraftsCompanion companion);

  /// Updates an existing aircraft row.
  Future<void> update(Aircraft item);

  /// Counts rows with the same registration excluding [currentId].
  Future<int> countDuplicateRegistration(String registration, int currentId);

  /// Counts flight rows referencing [aircraftId].
  Future<int> countFlightsForAircraft(int aircraftId);

  /// Counts simulator sessions referencing [aircraftId].
  Future<int> countSimSessionsForAircraft(int aircraftId);
}
