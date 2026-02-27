import 'package:drift/drift.dart';
import 'package:simplelog/core/text/search_normalizer.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/domain/repositories/crew_repository_contract.dart';

/// Drift-backed implementation of [CrewRepositoryContract].
class CrewRepository implements CrewRepositoryContract {
  /// Creates the repository with the shared app database.
  CrewRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<CrewRow>> watchCrew(String query) {
    final request = _db.select(_db.crew)
      ..orderBy([
        (table) => OrderingTerm.desc(table.isSelf),
        (table) => OrderingTerm.desc(table.isFavorite),
        (table) => OrderingTerm.asc(table.name),
      ]);

    final normalizedQuery = normalizeCrewSearch(query);

    return request.watch().map((rows) {
      final mapped = rows.map(CrewRow.new);
      if (normalizedQuery.isEmpty) {
        return mapped.toList();
      }
      return mapped.where((row) {
        final name = normalizeCrewSearch(row.crew.name);
        final email = normalizeCrewSearch(row.crew.email ?? '');
        final phone = normalizeCrewSearch(row.crew.phone ?? '');
        return name.contains(normalizedQuery) ||
            email.contains(normalizedQuery) ||
            phone.contains(normalizedQuery);
      }).toList();
    });
  }

  @override
  Future<void> toggleLock(CrewData item) async {
    await _db
        .update(_db.crew)
        .replace(
          item.copyWith(isLocked: !item.isLocked),
        );
  }

  @override
  Future<void> toggleFavorite(CrewData item) async {
    await _db
        .update(_db.crew)
        .replace(
          item.copyWith(isFavorite: !item.isFavorite),
        );
  }

  @override
  Future<void> delete(CrewData item) async {
    await _db.delete(_db.crew).delete(item);
  }

  @override
  Future<void> create(CrewCompanion companion, {required bool setSelf}) async {
    await _db.transaction(() async {
      if (setSelf) {
        await _db
            .update(_db.crew)
            .write(
              const CrewCompanion(isSelf: Value(false)),
            );
      }
      await _db.into(_db.crew).insert(companion);
    });
  }

  @override
  Future<void> update(CrewData item, {required bool setSelf}) async {
    await _db.transaction(() async {
      if (setSelf) {
        await _db
            .update(_db.crew)
            .write(
              const CrewCompanion(isSelf: Value(false)),
            );
      }
      await _db.update(_db.crew).replace(item);
    });
  }

  @override
  Future<int> countDuplicateName(String name, int currentId) async {
    final countExpr = _db.crew.id.count();
    final query = _db.selectOnly(_db.crew)
      ..addColumns([countExpr])
      ..where(
        _db.crew.name.lower().equals(name.toLowerCase()) &
            _db.crew.id.isNotIn([currentId]),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  @override
  Future<int> countFlightAssignmentsForCrew(int crewId) async {
    final countExpr = _db.flightCrewAssignments.id.count();
    final query = _db.selectOnly(_db.flightCrewAssignments)
      ..addColumns([countExpr])
      ..where(_db.flightCrewAssignments.crewId.equals(crewId));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  @override
  Future<int> countSimulatorAssignmentsForCrew(int crewId) async {
    final countExpr = _db.simulatorCrewAssignments.id.count();
    final query = _db.selectOnly(_db.simulatorCrewAssignments)
      ..addColumns([countExpr])
      ..where(_db.simulatorCrewAssignments.crewId.equals(crewId));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
