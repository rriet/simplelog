import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/domain/common/domain_validation.dart';
import 'package:simplelog/domain/repositories/airport_repository_contract.dart';

/// High‑level operations and validation rules for managing airports.
class AirportUseCases {
  /// Creates a new set of airport use cases backed by [_repository].
  AirportUseCases(this._repository);

  /// Repository used to read and persist airport data.
  final AirportRepositoryContract _repository;

  /// Watches airports matching [query] and [filters].
  Stream<List<AirportRow>> watchAirports(
    String query,
    AirportFilters filters,
  ) {
    return _repository.watchAirports(query, filters);
  }

  /// Toggles the locked state of [item].
  Future<void> toggleLock(Airport item) => _repository.toggleLock(item);

  /// Toggles the favorite state of [item].
  Future<void> toggleFavorite(Airport item) => _repository.toggleFavorite(item);

  /// Deletes [item] if allowed.
  Future<void> delete(Airport item) => _repository.delete(item);

  /// Creates a new airport from [companion].
  Future<int> create(AirportsCompanion companion) =>
      _repository.create(companion);

  /// Persists updates to [item].
  Future<void> update(Airport item) => _repository.update(item);

  /// Counts how many airports share the same ICAO code.
  Future<int> countDuplicateIcao(String icao, int currentId) =>
      _repository.countDuplicateIcao(icao, currentId);

  /// Counts flights that reference [airportId].
  Future<int> countFlightsUsingAirport(int airportId) =>
      _repository.countFlightsUsingAirport(airportId);

  /// Counts positioning legs that reference [airportId].
  Future<int> countPositioningsUsingAirport(int airportId) =>
      _repository.countPositioningsUsingAirport(airportId);

  /// Validates whether [companion] contains a unique, non‑empty ICAO code.
  Future<DomainValidation> validateCreate(AirportsCompanion companion) async {
    final icao = companion.icao.value.trim();
    if (icao.isEmpty) {
      return const DomainValidation.error('ICAO code is required.');
    }
    if (icao.length != 4) {
      return const DomainValidation.error('ICAO code must be 4 characters.');
    }
    final duplicate = await _repository.countDuplicateIcao(icao, -1);
    if (duplicate > 0) {
      return const DomainValidation.error('ICAO code already exists.');
    }
    return const DomainValidation.ok();
  }

  /// Validates whether [item] can be updated without violating constraints.
  Future<DomainValidation> validateUpdate(Airport item) async {
    final icao = item.icao.trim();
    if (icao.isEmpty) {
      return const DomainValidation.error('ICAO code is required.');
    }
    if (icao.length != 4) {
      return const DomainValidation.error('ICAO code must be 4 characters.');
    }
    final duplicate = await _repository.countDuplicateIcao(icao, item.id);
    if (duplicate > 0) {
      return const DomainValidation.error('ICAO code already exists.');
    }
    return const DomainValidation.ok();
  }

  /// Validates whether [item] can be safely deleted.
  Future<DomainValidation> validateDelete(Airport item) async {
    if (item.isLocked) {
      return const DomainValidation.error('This airport is locked.');
    }
    final flightCount = await _repository.countFlightsUsingAirport(item.id);
    final posCount = await _repository.countPositioningsUsingAirport(item.id);
    final usedCount = flightCount + posCount;
    if (usedCount > 0) {
      return DomainValidation.error(
        'Cannot delete. Airport used in $usedCount logbook entries.',
      );
    }
    return const DomainValidation.ok();
  }
}
