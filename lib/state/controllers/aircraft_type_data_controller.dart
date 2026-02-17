import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/state/providers/aircraft_type_repository_provider.dart';
import 'package:simplelog/state/providers/database_provider.dart';

import 'data_controller.dart';
import 'validation_result.dart';

class AircraftTypeDataController extends Notifier<void>
    implements DataController<AircraftType, AircraftTypesCompanion> {
  @override
  void build() {}

  @override
  Future<ValidationResult> validateCreate(
    AircraftTypesCompanion companion,
  ) async {
    final code = companion.code.value.trim();
    if (code.isEmpty) {
      return ValidationResult.error('Code is required.');
    }
    final repo = ref.read(aircraftTypeRepositoryProvider);
    final duplicate = await repo.countDuplicateCodes(code, -1);
    if (duplicate > 0) {
      return ValidationResult.error('Code already exists.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateUpdate(AircraftType item) async {
    final code = item.code.trim();
    if (code.isEmpty) {
      return ValidationResult.error('Code is required.');
    }
    final repo = ref.read(aircraftTypeRepositoryProvider);
    final duplicate = await repo.countDuplicateCodes(code, item.id);
    if (duplicate > 0) {
      return ValidationResult.error('Code already exists.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateDelete(AircraftType item) async {
    if (item.isLocked) {
      return ValidationResult.error('This aircraft type is locked.');
    }
    final db = ref.read(databaseProvider);
    final countExpr = db.aircrafts.id.count();
    final query = db.selectOnly(db.aircrafts)
      ..addColumns([countExpr])
      ..where(db.aircrafts.aircraftTypeId.equals(item.id));
    final row = await query.getSingle();
    final count = row.read(countExpr) ?? 0;
    if (count > 0) {
      return ValidationResult.error('This type is used by aircraft.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<int?> create(AircraftTypesCompanion companion) async {
    final normalized = _normalizeCompanion(companion);
    final validation = await validateCreate(normalized);
    if (!validation.isValid) {
      throw StateError(validation.message ?? 'Invalid aircraft type.');
    }
    final repo = ref.read(aircraftTypeRepositoryProvider);
    return repo.create(normalized);
  }

  @override
  Future<void> update(AircraftType item) async {
    final normalized = _normalizeItem(item);
    final validation = await validateUpdate(normalized);
    if (!validation.isValid) {
      throw StateError(validation.message ?? 'Invalid aircraft type.');
    }
    final repo = ref.read(aircraftTypeRepositoryProvider);
    await repo.update(normalized);
  }

  @override
  Future<void> delete(AircraftType item) async {
    final repo = ref.read(aircraftTypeRepositoryProvider);
    await repo.delete(item);
  }

  AircraftTypesCompanion _normalizeCompanion(
    AircraftTypesCompanion companion,
  ) {
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

  AircraftType _normalizeItem(AircraftType item) {
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
