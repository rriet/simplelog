import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';

class AircraftTypeRepository {
  AircraftTypeRepository(this._db);

  final AppDatabase _db;

  Stream<List<AircraftTypeRow>> watchAircraftTypes(String query) {
    final request = _db.select(_db.aircraftTypes)
      ..orderBy([
        (table) => OrderingTerm.asc(table.family),
        (table) => OrderingTerm.asc(table.code),
      ]);

    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      final term = '%$trimmed%';
      request.where((table) {
        final manufacturerMatches =
            table.manufacturer.isNotNull() & table.manufacturer.like(term);
        return table.code.like(term) |
            table.family.like(term) |
            table.longName.like(term) |
            manufacturerMatches;
      });
    }

    return request.watch().map(
          (rows) => rows.map(AircraftTypeRow.new).toList(),
        );
  }

  Future<void> toggleLock(AircraftType item) async {
    await _db.update(_db.aircraftTypes).replace(
          item.copyWith(isLocked: !item.isLocked),
        );
  }

  Future<int> countAircraftForType(int typeId) async {
    final countExpr = _db.aircrafts.id.count();
    final query = _db.selectOnly(_db.aircrafts)
      ..addColumns([countExpr])
      ..where(_db.aircrafts.aircraftTypeId.equals(typeId));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<void> delete(AircraftType item) async {
    await _db.delete(_db.aircraftTypes).delete(item);
  }

  Future<int> create(AircraftTypesCompanion companion) {
    return _db.into(_db.aircraftTypes).insert(companion);
  }

  Future<void> update(AircraftType item) async {
    await _db.update(_db.aircraftTypes).replace(item);
  }

  Future<int> countDuplicateCodes(String code, int currentId) async {
    final countExpr = _db.aircraftTypes.id.count();
    final query = _db.selectOnly(_db.aircraftTypes)
      ..addColumns([countExpr])
      ..where(
        _db.aircraftTypes.code.lower().equals(code.toLowerCase()) &
            _db.aircraftTypes.id.isNotIn([currentId]),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Stream<List<String>> watchFamilies() {
    final familyColumn = _db.aircraftTypes.family;
    final query = _db.selectOnly(_db.aircraftTypes)
      ..addColumns([familyColumn])
      ..groupBy([familyColumn])
      ..orderBy([OrderingTerm.asc(familyColumn)]);

    return query.watch().map(
          (rows) => rows
              .map((row) => row.read(familyColumn))
              .where((value) => value != null && value.trim().isNotEmpty)
              .cast<String>()
              .toList(),
        );
  }
}
