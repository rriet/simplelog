import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/features/airports/application/providers/airport_repository_provider.dart';

import 'package:simplelog/state/controllers/data_controller.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

/// Handles airport CRUD validation and mutation commands for the UI layer.
class AirportDataController extends Notifier<void>
    implements DataController<Airport, AirportsCompanion> {
  @override
  void build() {}

  @override
  Future<ValidationResult> validateCreate(
    AirportsCompanion companion,
  ) async {
    final useCases = ref.read(airportUseCasesProvider);
    final validation = await useCases.validateCreate(companion);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateUpdate(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    final validation = await useCases.validateUpdate(item);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateDelete(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    final validation = await useCases.validateDelete(item);
    if (!validation.isValid) {
      return ValidationResult.error(validation.message ?? 'Validation error.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<int?> create(AirportsCompanion companion) async {
    final useCases = ref.read(airportUseCasesProvider);
    return useCases.create(companion);
  }

  @override
  Future<void> update(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    await useCases.update(item);
  }

  @override
  Future<void> delete(Airport item) async {
    final useCases = ref.read(airportUseCasesProvider);
    await useCases.delete(item);
  }
}
