import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_row.dart';

/// Public API documentation.
abstract class CrewRepositoryContract {
  /// Public API documentation.
  Stream<List<CrewRow>> watchCrew(String query);
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleLock(CrewData item);
  /// Public API documentation.
  Future<void> toggleFavorite(CrewData item);
  /// Public API documentation.
  Future<void> delete(CrewData item);
  /// Public API documentation.
  Future<void> create(CrewCompanion companion, {required bool setSelf});
  /// Public API documentation.
  Future<void> update(CrewData item, {required bool setSelf});
  /// Public API documentation.
  Future<int> countDuplicateName(String name, int currentId);
  /// Public API documentation.
  Future<int> countFlightAssignmentsForCrew(int crewId);
  /// Public API documentation.
  Future<int> countSimulatorAssignmentsForCrew(int crewId);
}
