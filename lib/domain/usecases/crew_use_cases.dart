import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/domain/common/domain_validation.dart';
import 'package:simplelog/domain/repositories/crew_repository_contract.dart';

/// Public API documentation.
class CrewUseCases {
  /// Public API documentation.
  CrewUseCases(this._repository);

  /// Public API documentation.
  final CrewRepositoryContract _repository;

  /// Public API documentation.
  Stream<List<CrewRow>> watchCrew(String query) => _repository.watchCrew(query);

  /// Public API documentation.
  Future<void> toggleLock(CrewData item) => _repository.toggleLock(item);
  /// Public API documentation.
  Future<void> toggleFavorite(CrewData item) =>
      _repository.toggleFavorite(item);
  /// Public API documentation.
  Future<void> delete(CrewData item) => _repository.delete(item);
  /// Public API documentation.
  Future<void> create(CrewCompanion companion, {required bool setSelf}) =>
      /// Public API documentation.
      _repository.create(companion, setSelf: setSelf);
  /// Public API documentation.
  Future<void> update(CrewData item, {required bool setSelf}) =>
      /// Public API documentation.
      _repository.update(item, setSelf: setSelf);
  /// Public API documentation.
  Future<int> countDuplicateName(String name, int currentId) =>
      _repository.countDuplicateName(name, currentId);
  /// Public API documentation.
  Future<int> countFlightAssignmentsForCrew(int crewId) =>
      _repository.countFlightAssignmentsForCrew(crewId);
  /// Public API documentation.
  Future<int> countSimulatorAssignmentsForCrew(int crewId) =>
      _repository.countSimulatorAssignmentsForCrew(crewId);

  /// Public API documentation.
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

  /// Public API documentation.
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

  /// Public API documentation.
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
