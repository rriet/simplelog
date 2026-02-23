import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/domain/common/domain_validation.dart';
import 'package:simplelog/domain/repositories/aircraft_type_repository_contract.dart';

/// Public API documentation.
class AircraftTypeUseCases {
  /// Public API documentation.
  AircraftTypeUseCases(this._repository);

  /// Public API documentation.
  final AircraftTypeRepositoryContract _repository;

  /// Public API documentation.
  Stream<List<AircraftTypeRow>> watchAircraftTypes(String query) {
    /// Public API documentation.
    return _repository.watchAircraftTypes(query);
  }

  /// Public API documentation.
  Stream<List<String>> watchFamilies() {
    /// Public API documentation.
    return _repository.watchFamilies();
  }
/// Public API documentation.

  /// Public API documentation.
  Future<void> toggleLock(AircraftType item) => _repository.toggleLock(item);
  /// Public API documentation.
  Future<int> countAircraftForType(int typeId) =>
      _repository.countAircraftForType(typeId);
  /// Public API documentation.
  Future<void> delete(AircraftType item) => _repository.delete(item);
  /// Public API documentation.
  Future<int> create(AircraftTypesCompanion companion) =>
      _repository.create(companion);
  /// Public API documentation.
  Future<void> update(AircraftType item) => _repository.update(item);
  /// Public API documentation.
  Future<int> countDuplicateCodes(String code, int currentId) =>
      _repository.countDuplicateCodes(code, currentId);

  /// Public API documentation.
  Future<DomainValidation> validateCreate(
    AircraftTypesCompanion companion,
  ) async {
    /// Public API documentation.
    final code = companion.code.value.trim();
    if (code.isEmpty) {
      return const DomainValidation.error('Code is required.');
    }
    final duplicate = await _repository.countDuplicateCodes(code, -1);
    if (duplicate > 0) {
      return const DomainValidation.error('Code already exists.');
    }
    return const DomainValidation.ok();
  }

  /// Public API documentation.
  Future<DomainValidation> validateUpdate(AircraftType item) async {
    final code = item.code.trim();
    if (code.isEmpty) {
      return const DomainValidation.error('Code is required.');
    }
    final duplicate = await _repository.countDuplicateCodes(code, item.id);
    if (duplicate > 0) {
      return const DomainValidation.error('Code already exists.');
    }
    return const DomainValidation.ok();
  }
/// Public API documentation.

  /// Public API documentation.
  Future<DomainValidation> validateDelete(AircraftType item) async {
    if (item.isLocked) {
      return const DomainValidation.error('This aircraft type is locked.');
    }
    final count = await _repository.countAircraftForType(item.id);
    if (count > 0) {
      return const DomainValidation.error('This type is used by aircraft.');
    }
    return const DomainValidation.ok();
  }

  /// Public API documentation.
  AircraftTypesCompanion normalizeCompanion(AircraftTypesCompanion companion) {
    final code = companion.code.value.trim();
    final familyRaw = companion.family.value.trim();
    final longNameRaw = companion.longName.value.trim();
    final family = familyRaw.isEmpty ? code : familyRaw;
    final longName = longNameRaw.isEmpty ? code : longNameRaw;
    return companion.copyWith(
      code: Value(code),
      family: Value(family),
      longName: Value(longName),
    );
  }

  /// Public API documentation.
  AircraftType normalizeItem(AircraftType item) {
    final code = item.code.trim();
    final familyRaw = item.family.trim();
    final longNameRaw = item.longName.trim();
    final family = familyRaw.isEmpty ? code : familyRaw;
    final longName = longNameRaw.isEmpty ? code : longNameRaw;
    return item.copyWith(
      code: code,
      family: family,
      longName: longName,
    );
  }
}
