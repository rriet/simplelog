import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';

/// Public API documentation.
abstract class AircraftTypeRepositoryContract {
  /// Public API documentation.
  Stream<List<AircraftTypeRow>> watchAircraftTypes(String query);
  /// Public API documentation.
  Stream<List<String>> watchFamilies();
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleLock(AircraftType item);
  /// Public API documentation.
  Future<int> countAircraftForType(int typeId);
  /// Public API documentation.
  Future<void> delete(AircraftType item);
  /// Public API documentation.
  Future<int> create(AircraftTypesCompanion companion);
  /// Public API documentation.
  Future<void> update(AircraftType item);
  /// Public API documentation.
  Future<int> countDuplicateCodes(String code, int currentId);
}
