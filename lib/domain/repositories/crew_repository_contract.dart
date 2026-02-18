import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_row.dart';

abstract class CrewRepositoryContract {
  Stream<List<CrewRow>> watchCrew(String query);

  Future<void> toggleLock(CrewData item);
  Future<void> toggleFavorite(CrewData item);
  Future<void> delete(CrewData item);
  Future<void> create(CrewCompanion companion, {required bool setSelf});
  Future<void> update(CrewData item, {required bool setSelf});
  Future<int> countDuplicateName(String name, int currentId);
  Future<int> countFlightAssignmentsForCrew(int crewId);
  Future<int> countSimulatorAssignmentsForCrew(int crewId);
}
