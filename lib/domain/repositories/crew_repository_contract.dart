import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_row.dart';

/// Contract for crew member management and assignment usage checks.
abstract class CrewRepositoryContract {
  /// Streams crew rows matching [query].
  Stream<List<CrewRow>> watchCrew(String query);

  /// Toggles lock state for [item].
  Future<void> toggleLock(CrewData item);

  /// Toggles favorite state for [item].
  Future<void> toggleFavorite(CrewData item);

  /// Deletes [item].
  Future<void> delete(CrewData item);

  /// Creates a crew row and optionally marks it as self when [setSelf] is true.
  Future<void> create(CrewCompanion companion, {required bool setSelf});

  /// Updates [item] and optionally updates the self marker when [setSelf].
  Future<void> update(CrewData item, {required bool setSelf});

  /// Counts duplicate crew names excluding [currentId].
  Future<int> countDuplicateName(String name, int currentId);

  /// Counts flight crew assignments for [crewId].
  Future<int> countFlightAssignmentsForCrew(int crewId);

  /// Counts simulator crew assignments for [crewId].
  Future<int> countSimulatorAssignmentsForCrew(int crewId);
}
