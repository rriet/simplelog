import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/aircraft_types/application/providers/aircraft_type_repository_provider.dart';

import 'package:simplelog/state/controllers/data_controller.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

/// Public API documentation.
class AircraftTypeDataController extends Notifier<void>
    implements DataController<AircraftType, AircraftTypesCompanion> {
  @override
  void build() {}

  @override
  Future<ValidationResult> validateCreate(
    AircraftTypesCompanion companion,
  ) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    final validation = await useCases.validateCreate(companion);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateUpdate(AircraftType item) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    final validation = await useCases.validateUpdate(item);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateDelete(AircraftType item) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    final validation = await useCases.validateDelete(item);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<int?> create(AircraftTypesCompanion companion) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    final normalized = useCases.normalizeCompanion(companion);
    final validation = await validateCreate(normalized);
    if (!validation.isValid) {
      throw StateError(validation.message ?? 'Invalid aircraft type.');
    }
    return useCases.create(normalized);
  }

  @override
  Future<void> update(AircraftType item) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    final normalized = useCases.normalizeItem(item);
    final validation = await validateUpdate(normalized);
    if (!validation.isValid) {
      throw StateError(validation.message ?? 'Invalid aircraft type.');
    }
    await useCases.update(normalized);
  }

  @override
  Future<void> delete(AircraftType item) async {
    final useCases = ref.read(aircraftTypeUseCasesProvider);
    await useCases.delete(item);
  }
}
