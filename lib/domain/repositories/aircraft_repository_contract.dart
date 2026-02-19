import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';

abstract class AircraftRepositoryContract {
  Stream<List<AircraftRow>> watchAircraft(String query);
  Future<List<AircraftRow>> fetchAircraftByType(int aircraftTypeId);

  Future<void> toggleLock(Aircraft item);
  Future<void> toggleFavorite(Aircraft item);
  Future<void> delete(Aircraft item);
  Future<int> create(AircraftsCompanion companion);
  Future<void> update(Aircraft item);
  Future<int> countDuplicateRegistration(String registration, int currentId);
  Future<int> countFlightsForAircraft(int aircraftId);
  Future<int> countSimSessionsForAircraft(int aircraftId);
}
