import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/crew/application/providers/crew_repository_provider.dart';

import 'package:simplelog/state/controllers/data_controller.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

/// Handles crew CRUD validation and mutation commands for the UI layer.
class CrewDataController extends Notifier<void>
    implements DataController<CrewData, CrewCompanion> {
  @override
  void build() {}

  @override
  Future<ValidationResult> validateCreate(CrewCompanion companion) async {
    final useCases = ref.read(crewUseCasesProvider);
    final validation = await useCases.validateCreate(companion);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateUpdate(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    final validation = await useCases.validateUpdate(item);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateDelete(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    final validation = await useCases.validateDelete(item);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<int?> create(CrewCompanion companion) async {
    final useCases = ref.read(crewUseCasesProvider);
    await useCases.create(companion, setSelf: companion.isSelf.value);
    return null;
  }

  @override
  Future<void> update(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    await useCases.update(item, setSelf: item.isSelf);
  }

  @override
  Future<void> delete(CrewData item) async {
    final useCases = ref.read(crewUseCasesProvider);
    await useCases.delete(item);
  }
}
