import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';

/// Contract for aircraft-type catalog operations.
abstract class AircraftTypeRepositoryContract {
  /// Streams aircraft types matching [query].
  Stream<List<AircraftTypeRow>> watchAircraftTypes(String query);

  /// Streams distinct aircraft type families for filter UIs.
  Stream<List<String>> watchFamilies();

  /// Toggles lock state on [item].
  Future<void> toggleLock(AircraftType item);

  /// Counts aircraft rows using [typeId].
  Future<int> countAircraftForType(int typeId);

  /// Deletes [item].
  Future<void> delete(AircraftType item);

  /// Creates a new aircraft type and returns its generated id.
  Future<int> create(AircraftTypesCompanion companion);

  /// Updates an existing aircraft type.
  Future<void> update(AircraftType item);

  /// Counts rows with same code excluding [currentId].
  Future<int> countDuplicateCodes(String code, int currentId);
}
