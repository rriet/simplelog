import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/state/providers/crew_repository_provider.dart';
import 'package:simplelog/state/providers/database_provider.dart';

import 'data_controller.dart';
import 'validation_result.dart';

class CrewDataController extends Notifier<void>
    implements DataController<CrewData, CrewCompanion> {
  @override
  void build() {}

  @override
  Future<ValidationResult> validateCreate(CrewCompanion companion) async {
    final name = companion.name.value.trim();
    if (name.isEmpty) {
      return ValidationResult.error('Name is required.');
    }
    final repo = ref.read(crewRepositoryProvider);
    final duplicate = await repo.countDuplicateName(name, -1);
    if (duplicate > 0) {
      return ValidationResult.error('Name already exists.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateUpdate(CrewData item) async {
    final name = item.name.trim();
    if (name.isEmpty) {
      return ValidationResult.error('Name is required.');
    }
    final repo = ref.read(crewRepositoryProvider);
    final duplicate = await repo.countDuplicateName(name, item.id);
    if (duplicate > 0) {
      return ValidationResult.error('Name already exists.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateDelete(CrewData item) async {
    if (item.isLocked) {
      return ValidationResult.error('This crew member is locked.');
    }
    final db = ref.read(databaseProvider);
    final flightCountExpr = db.flightCrewAssignments.id.count();
    final flightQuery = db.selectOnly(db.flightCrewAssignments)
      ..addColumns([flightCountExpr])
      ..where(db.flightCrewAssignments.crewId.equals(item.id));
    final flightRow = await flightQuery.getSingle();
    final flightCount = flightRow.read(flightCountExpr) ?? 0;

    final simCountExpr = db.simulatorCrewAssignments.id.count();
    final simQuery = db.selectOnly(db.simulatorCrewAssignments)
      ..addColumns([simCountExpr])
      ..where(db.simulatorCrewAssignments.crewId.equals(item.id));
    final simRow = await simQuery.getSingle();
    final simCount = simRow.read(simCountExpr) ?? 0;

    final usedCount = flightCount + simCount;
    if (usedCount > 0) {
      return ValidationResult.error(
        'Cannot delete. Crew member used in $usedCount logbook entries.',
      );
    }
    return ValidationResult.ok();
  }

  @override
  Future<int?> create(CrewCompanion companion) async {
    final repo = ref.read(crewRepositoryProvider);
    await repo.create(companion, setSelf: companion.isSelf.value);
    return null;
  }

  @override
  Future<void> update(CrewData item) async {
    final repo = ref.read(crewRepositoryProvider);
    await repo.update(item, setSelf: item.isSelf);
  }

  @override
  Future<void> delete(CrewData item) async {
    final repo = ref.read(crewRepositoryProvider);
    await repo.delete(item);
  }
}
