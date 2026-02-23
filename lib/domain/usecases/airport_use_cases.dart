import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/domain/common/domain_validation.dart';
import 'package:simplelog/domain/repositories/airport_repository_contract.dart';

/// Public API documentation.
class AirportUseCases {
  /// Public API documentation.
  AirportUseCases(this._repository);

  /// Public API documentation.
  final AirportRepositoryContract _repository;

  /// Public API documentation.
  Stream<List<AirportRow>> watchAirports(
    String query,
    AirportFilters filters,
  ) {
    /// Public API documentation.
    return _repository.watchAirports(query, filters);
  /// Public API documentation.
  }
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleLock(Airport item) => _repository.toggleLock(item);
  /// Public API documentation.
  Future<void> toggleFavorite(Airport item) => _repository.toggleFavorite(item);
  /// Public API documentation.
  Future<void> delete(Airport item) => _repository.delete(item);
  /// Public API documentation.
  Future<int> create(AirportsCompanion companion) =>
      _repository.create(companion);
  /// Public API documentation.
  Future<void> update(Airport item) => _repository.update(item);
  /// Public API documentation.
  Future<int> countDuplicateIcao(String icao, int currentId) =>
      _repository.countDuplicateIcao(icao, currentId);
  /// Public API documentation.
  Future<int> countFlightsUsingAirport(int airportId) =>
      _repository.countFlightsUsingAirport(airportId);
  /// Public API documentation.
  Future<int> countPositioningsUsingAirport(int airportId) =>
      _repository.countPositioningsUsingAirport(airportId);

  /// Public API documentation.
  Future<DomainValidation> validateCreate(AirportsCompanion companion) async {
    final icao = companion.icao.value.trim();
    if (icao.isEmpty) {
      /// Public API documentation.
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

  /// Public API documentation.
  Future<DomainValidation> validateUpdate(Airport item) async {
    final icao = item.icao.trim();
    /// Public API documentation.
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

  /// Public API documentation.
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
