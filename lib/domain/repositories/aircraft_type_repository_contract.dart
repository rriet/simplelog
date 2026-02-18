import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';

abstract class AircraftTypeRepositoryContract {
  Stream<List<AircraftTypeRow>> watchAircraftTypes(String query);
  Stream<List<String>> watchFamilies();

  Future<void> toggleLock(AircraftType item);
  Future<int> countAircraftForType(int typeId);
  Future<void> delete(AircraftType item);
  Future<int> create(AircraftTypesCompanion companion);
  Future<void> update(AircraftType item);
  Future<int> countDuplicateCodes(String code, int currentId);
}
