import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/domain/common/domain_validation.dart';
import 'package:simplelog/domain/repositories/aircraft_repository_contract.dart';

/// High‑level operations and validation rules for managing aircraft.
class AircraftUseCases {
  /// Creates a new set of aircraft use cases backed by [_repository].
  AircraftUseCases(this._repository);

  /// Repository used to read and persist aircraft data.
  final AircraftRepositoryContract _repository;

  /// Watches aircraft that match the given search [query].
  Stream<List<AircraftRow>> watchAircraft(String query) {
    return _repository.watchAircraft(query);
  }

  /// Fetches aircraft filtered by [aircraftTypeId].
  Future<List<AircraftRow>> fetchAircraftByType(int aircraftTypeId) {
    return _repository.fetchAircraftByType(aircraftTypeId);
  }

  /// Toggles the locked state of [item].
  Future<void> toggleLock(Aircraft item) => _repository.toggleLock(item);

  /// Toggles the favorite state of [item].
  Future<void> toggleFavorite(Aircraft item) =>
      _repository.toggleFavorite(item);

  /// Deletes [item] if allowed.
  Future<void> delete(Aircraft item) => _repository.delete(item);

  /// Creates a new aircraft from [companion].
  Future<int> create(AircraftsCompanion companion) =>
      _repository.create(companion);

  /// Persists updates to [item].
  Future<void> update(Aircraft item) => _repository.update(item);

  /// Counts how many other aircraft share the same [registration].
  Future<int> countDuplicateRegistration(String registration, int currentId) {
    return _repository.countDuplicateRegistration(registration, currentId);
  }

  /// Counts flights that reference [aircraftId].
  Future<int> countFlightsForAircraft(int aircraftId) {
    return _repository.countFlightsForAircraft(aircraftId);
  }

  /// Counts simulator sessions that reference [aircraftId].
  Future<int> countSimSessionsForAircraft(int aircraftId) {
    return _repository.countSimSessionsForAircraft(aircraftId);
  }

  /// Validates whether [companion] contains a unique, non‑empty registration.
  Future<DomainValidation> validateCreate(AircraftsCompanion companion) async {
    final registration = companion.registration.value.trim();
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

  /// Validates whether [item] can be updated without violating constraints.
  Future<DomainValidation> validateUpdate(Aircraft item) async {
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

  /// Validates whether [item] can be safely deleted.
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
