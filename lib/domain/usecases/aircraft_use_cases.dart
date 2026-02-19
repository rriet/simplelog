import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/domain/common/domain_validation.dart';
import 'package:simplelog/domain/repositories/aircraft_repository_contract.dart';

class AircraftUseCases {
  AircraftUseCases(this._repository);

  final AircraftRepositoryContract _repository;

  Stream<List<AircraftRow>> watchAircraft(String query) {
    return _repository.watchAircraft(query);
  }

  Future<List<AircraftRow>> fetchAircraftByType(int aircraftTypeId) {
    return _repository.fetchAircraftByType(aircraftTypeId);
  }

  Future<void> toggleLock(Aircraft item) => _repository.toggleLock(item);
  Future<void> toggleFavorite(Aircraft item) => _repository.toggleFavorite(item);
  Future<void> delete(Aircraft item) => _repository.delete(item);
  Future<int> create(AircraftsCompanion companion) => _repository.create(companion);
  Future<void> update(Aircraft item) => _repository.update(item);

  Future<int> countDuplicateRegistration(String registration, int currentId) {
    return _repository.countDuplicateRegistration(registration, currentId);
  }

  Future<int> countFlightsForAircraft(int aircraftId) {
    return _repository.countFlightsForAircraft(aircraftId);
  }

  Future<int> countSimSessionsForAircraft(int aircraftId) {
    return _repository.countSimSessionsForAircraft(aircraftId);
  }

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
