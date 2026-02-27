import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/domain/common/domain_validation.dart';
import 'package:simplelog/domain/repositories/crew_repository_contract.dart';

/// Use-case facade for crew CRUD and validation workflows.
class CrewUseCases {
  /// Creates use-cases bound to a crew repository implementation.
  CrewUseCases(this._repository);

  /// Repository used by this use-case facade.
  final CrewRepositoryContract _repository;

  /// Streams crew rows filtered by free-text [query].
  Stream<List<CrewRow>> watchCrew(String query) => _repository.watchCrew(query);

  /// Toggles lock status for [item].
  Future<void> toggleLock(CrewData item) => _repository.toggleLock(item);

  /// Toggles favorite status for [item].
  Future<void> toggleFavorite(CrewData item) =>
      _repository.toggleFavorite(item);

  /// Deletes [item] from storage.
  Future<void> delete(CrewData item) => _repository.delete(item);

  /// Creates a crew row and optionally sets it as self when [setSelf] is true.
  Future<void> create(CrewCompanion companion, {required bool setSelf}) =>
      _repository.create(companion, setSelf: setSelf);

  /// Updates [item] and optionally sets it as self when [setSelf] is true.
  Future<void> update(CrewData item, {required bool setSelf}) =>
      _repository.update(item, setSelf: setSelf);

  /// Counts duplicate names excluding [currentId].
  Future<int> countDuplicateName(String name, int currentId) =>
      _repository.countDuplicateName(name, currentId);

  /// Counts flight assignments for crew [crewId].
  Future<int> countFlightAssignmentsForCrew(int crewId) =>
      _repository.countFlightAssignmentsForCrew(crewId);

  /// Counts simulator assignments for crew [crewId].
  Future<int> countSimulatorAssignmentsForCrew(int crewId) =>
      _repository.countSimulatorAssignmentsForCrew(crewId);

  /// Validates create input before inserting a new crew row.
  Future<DomainValidation> validateCreate(CrewCompanion companion) async {
    final name = companion.name.value.trim();
    if (name.isEmpty) {
      return const DomainValidation.error('Name is required.');
    }
    final duplicate = await _repository.countDuplicateName(name, -1);
    if (duplicate > 0) {
      return const DomainValidation.error('Name already exists.');
    }
    return const DomainValidation.ok();
  }

  /// Validates update input before persisting a crew row.
  Future<DomainValidation> validateUpdate(CrewData item) async {
    final name = item.name.trim();
    if (name.isEmpty) {
      return const DomainValidation.error('Name is required.');
    }
    final duplicate = await _repository.countDuplicateName(name, item.id);
    if (duplicate > 0) {
      return const DomainValidation.error('Name already exists.');
    }
    return const DomainValidation.ok();
  }

  /// Validates whether [item] can be deleted.
  ///
  /// Deletion is blocked when row is locked or referenced by any entry.
  Future<DomainValidation> validateDelete(CrewData item) async {
    if (item.isLocked) {
      return const DomainValidation.error('This crew member is locked.');
    }
    final flightCount = await _repository.countFlightAssignmentsForCrew(
      item.id,
    );
    final simCount = await _repository.countSimulatorAssignmentsForCrew(
      item.id,
    );
    final usedCount = flightCount + simCount;
    if (usedCount > 0) {
      return DomainValidation.error(
        'Cannot delete. Crew member used in $usedCount logbook entries.',
      );
    }
    return const DomainValidation.ok();
  }
}
