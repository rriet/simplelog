import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/domain/common/domain_validation.dart';
import 'package:simplelog/domain/repositories/aircraft_type_repository_contract.dart';

/// Use-case facade for aircraft type management.
class AircraftTypeUseCases {
  /// Creates use-cases wired to an [AircraftTypeRepositoryContract].
  AircraftTypeUseCases(this._repository);

  final AircraftTypeRepositoryContract _repository;

  /// Streams aircraft types filtered by [query].
  Stream<List<AircraftTypeRow>> watchAircraftTypes(String query) {
    return _repository.watchAircraftTypes(query);
  }

  /// Streams distinct family values for filtering/grouping.
  Stream<List<String>> watchFamilies() {
    return _repository.watchFamilies();
  }

  /// Toggles lock state of [item].
  Future<void> toggleLock(AircraftType item) => _repository.toggleLock(item);

  /// Counts aircraft rows referencing [typeId].
  Future<int> countAircraftForType(int typeId) =>
      _repository.countAircraftForType(typeId);

  /// Deletes [item].
  Future<void> delete(AircraftType item) => _repository.delete(item);

  /// Creates a new type and returns its id.
  Future<int> create(AircraftTypesCompanion companion) =>
      _repository.create(companion);

  /// Updates [item].
  Future<void> update(AircraftType item) => _repository.update(item);

  /// Counts duplicate codes excluding [currentId].
  Future<int> countDuplicateCodes(String code, int currentId) =>
      _repository.countDuplicateCodes(code, currentId);

  /// Validates a new type before insertion.
  Future<DomainValidation> validateCreate(
    AircraftTypesCompanion companion,
  ) async {
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

  /// Validates an existing type before update.
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

  /// Validates whether [item] can be safely deleted.
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

  /// Normalizes code/family/name values before create.
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

  /// Normalizes type fields before update.
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
