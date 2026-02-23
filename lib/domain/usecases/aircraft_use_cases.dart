import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/domain/common/domain_validation.dart';
import 'package:simplelog/domain/repositories/aircraft_repository_contract.dart';

/// Public API documentation.
class AircraftUseCases {
  /// Public API documentation.
  AircraftUseCases(this._repository);

  /// Public API documentation.
  final AircraftRepositoryContract _repository;

  /// Public API documentation.
  Stream<List<AircraftRow>> watchAircraft(String query) {
    /// Public API documentation.
    return _repository.watchAircraft(query);
  }

  /// Public API documentation.
  Future<List<AircraftRow>> fetchAircraftByType(int aircraftTypeId) {
    /// Public API documentation.
    return _repository.fetchAircraftByType(aircraftTypeId);
  }
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleLock(Aircraft item) => _repository.toggleLock(item);
  /// Public API documentation.
  Future<void> toggleFavorite(Aircraft item) =>
      /// Public API documentation.
      _repository.toggleFavorite(item);
  /// Public API documentation.
  Future<void> delete(Aircraft item) => _repository.delete(item);
  /// Public API documentation.
  Future<int> create(AircraftsCompanion companion) =>
      _repository.create(companion);
  /// Public API documentation.
  Future<void> update(Aircraft item) => _repository.update(item);
/// Public API documentation.

  /// Public API documentation.
  Future<int> countDuplicateRegistration(String registration, int currentId) {
    return _repository.countDuplicateRegistration(registration, currentId);
  /// Public API documentation.
  }

  /// Public API documentation.
  Future<int> countFlightsForAircraft(int aircraftId) {
    return _repository.countFlightsForAircraft(aircraftId);
  }

  /// Public API documentation.
  Future<int> countSimSessionsForAircraft(int aircraftId) {
    return _repository.countSimSessionsForAircraft(aircraftId);
  }

  /// Public API documentation.
  Future<DomainValidation> validateCreate(AircraftsCompanion companion) async {
    final registration = companion.registration.value.trim();
    /// Public API documentation.
    if (registration.isEmpty) {
      return const DomainValidation.error('Registration is required.');
    }
    final duplicate = await _repository.countDuplicateRegistration(
      registration,
      -1,
    );
    if (duplicate > 0) {
      return const DomainValidation.error('Registration already exists.');
    }
    return const DomainValidation.ok();
  }

  /// Public API documentation.
  Future<DomainValidation> validateUpdate(Aircraft item) async {
    /// Public API documentation.
    final registration = item.registration.trim();
    if (registration.isEmpty) {
      return const DomainValidation.error('Registration is required.');
    }
    final duplicate = await _repository.countDuplicateRegistration(
      registration,
      item.id,
    );
    if (duplicate > 0) {
      return const DomainValidation.error('Registration already exists.');
    }
    return const DomainValidation.ok();
  }

  /// Public API documentation.
  Future<DomainValidation> validateDelete(Aircraft item) async {
    if (item.isLocked) {
      return const DomainValidation.error('This aircraft is locked.');
    }
    final flightCount = await _repository.countFlightsForAircraft(item.id);
    final simCount = await _repository.countSimSessionsForAircraft(item.id);
    if (flightCount + simCount > 0) {
      if (item.isSimulator) {
        final count = simCount == 0 ? flightCount : simCount;
        return DomainValidation.error(
          'Simulator used in $count training sessions.',
        );
      }
      return DomainValidation.error('Aircraft used in $flightCount flights.');
    }
    return const DomainValidation.ok();
  }
}
