import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_row.dart';

class CrewRepository {
  CrewRepository(this._db);

  final AppDatabase _db;

  Stream<List<CrewRow>> watchCrew(String query) {
    final request = _db.select(_db.crew)
      ..orderBy([
        (table) => OrderingTerm.desc(table.isFavorite),
        (table) => OrderingTerm.asc(table.name),
      ]);

    final normalizedQuery = _normalizeSearch(query);
    if (normalizedQuery.isEmpty) {
      return request.watch().map(
            (rows) => rows.map(CrewRow.new).toList(),
          );
    }

    return request.watch().map((items) {
      return items.where((item) {
        final name = item.name.toLowerCase();
        final email = (item.email ?? '').toLowerCase();
        final phoneDigits = _digitsOnly(item.phone ?? '');
        final queryDigits = _digitsOnly(normalizedQuery);

        final matchesText = name.contains(normalizedQuery) ||
            email.contains(normalizedQuery);
        final matchesPhone = queryDigits.isNotEmpty &&
            phoneDigits.contains(queryDigits);

        return matchesText || matchesPhone;
      }).map(CrewRow.new).toList();
    });
  }

  Future<void> toggleLock(CrewData item) async {
    await _db.update(_db.crew).replace(
          item.copyWith(isLocked: !item.isLocked),
        );
  }

  Future<void> toggleFavorite(CrewData item) async {
    await _db.update(_db.crew).replace(
          item.copyWith(isFavorite: !item.isFavorite),
        );
  }

  Future<void> delete(CrewData item) async {
    await _db.delete(_db.crew).delete(item);
  }

  Future<void> create(CrewCompanion companion, {required bool setSelf}) async {
    await _db.transaction(() async {
      if (setSelf) {
        await _db.update(_db.crew).write(
              const CrewCompanion(isSelf: Value(false)),
            );
      }
      await _db.into(_db.crew).insert(companion);
    });
  }

  Future<void> update(CrewData item, {required bool setSelf}) async {
    await _db.transaction(() async {
      if (setSelf) {
        await _db.update(_db.crew).write(
              const CrewCompanion(isSelf: Value(false)),
            );
      }
      await _db.update(_db.crew).replace(item);
    });
  }

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

  String _normalizeSearch(String value) => value.trim().toLowerCase();

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');
}
