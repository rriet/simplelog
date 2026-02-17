import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/state/providers/aircraft_repository_provider.dart';
import 'package:simplelog/state/providers/database_provider.dart';

import 'data_controller.dart';
import 'validation_result.dart';

class AircraftDataController extends Notifier<void>
    implements DataController<Aircraft, AircraftsCompanion> {
  @override
  void build() {}

  @override
  Future<ValidationResult> validateCreate(
    AircraftsCompanion companion,
  ) async {
    final registration = companion.registration.value.trim();
    if (registration.isEmpty) {
      return ValidationResult.error('Registration is required.');
    }
    final repo = ref.read(aircraftRepositoryProvider);
    final duplicate = await repo.countDuplicateRegistration(registration, -1);
    if (duplicate > 0) {
      return ValidationResult.error('Registration already exists.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateUpdate(Aircraft item) async {
    final registration = item.registration.trim();
    if (registration.isEmpty) {
      return ValidationResult.error('Registration is required.');
    }
    final repo = ref.read(aircraftRepositoryProvider);
    final duplicate =
        await repo.countDuplicateRegistration(registration, item.id);
    if (duplicate > 0) {
      return ValidationResult.error('Registration already exists.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateDelete(Aircraft item) async {
    if (item.isLocked) {
      return ValidationResult.error('This aircraft is locked.');
    }
    final db = ref.read(databaseProvider);
    final flightCountExpr = db.flights.id.count();
    final flightQuery = db.selectOnly(db.flights)
      ..addColumns([flightCountExpr])
      ..where(db.flights.aircraftId.equals(item.id));
    final flightRow = await flightQuery.getSingle();
    final flightCount = flightRow.read(flightCountExpr) ?? 0;

    final simCountExpr = db.simulatorTrainings.id.count();
    final simQuery = db.selectOnly(db.simulatorTrainings)
      ..addColumns([simCountExpr])
      ..where(db.simulatorTrainings.aircraftId.equals(item.id));
    final simRow = await simQuery.getSingle();
    final simCount = simRow.read(simCountExpr) ?? 0;

    if (flightCount + simCount > 0) {
      if (item.isSimulator) {
        final count = simCount == 0 ? flightCount : simCount;
        return ValidationResult.error(
          'Simulator used in $count training sessions.',
        );
      }
      return ValidationResult.error(
        'Aircraft used in $flightCount flights.',
      );
    }
    return ValidationResult.ok();
  }

  @override
  Future<int?> create(AircraftsCompanion companion) async {
    final repo = ref.read(aircraftRepositoryProvider);
    return repo.create(companion);
  }

  @override
  Future<void> update(Aircraft item) async {
    final repo = ref.read(aircraftRepositoryProvider);
    await repo.update(item);
  }

  @override
  Future<void> delete(Aircraft item) async {
    final repo = ref.read(aircraftRepositoryProvider);
    await repo.delete(item);
  }
}
