import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/aircraft/application/providers/aircraft_repository_provider.dart';

import 'package:simplelog/state/controllers/data_controller.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

class AircraftDataController extends Notifier<void>
    implements DataController<Aircraft, AircraftsCompanion> {
  @override
  void build() {}

  @override
  Future<ValidationResult> validateCreate(
    AircraftsCompanion companion,
  ) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    final validation = await useCases.validateCreate(companion);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateUpdate(Aircraft item) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    final validation = await useCases.validateUpdate(item);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateDelete(Aircraft item) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    final validation = await useCases.validateDelete(item);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<int?> create(AircraftsCompanion companion) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    return useCases.create(companion);
  }

  @override
  Future<void> update(Aircraft item) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    await useCases.update(item);
  }

  @override
  Future<void> delete(Aircraft item) async {
    final useCases = ref.read(aircraftUseCasesProvider);
    await useCases.delete(item);
  }
}
