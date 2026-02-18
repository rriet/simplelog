// ignore_for_file: annotate_overrides

import 'package:drift/drift.dart';
import 'package:simplelog/core/text/search_normalizer.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/domain/repositories/aircraft_type_repository_contract.dart';

class AircraftTypeRepository implements AircraftTypeRepositoryContract {
  AircraftTypeRepository(this._db);

  final AppDatabase _db;

  Stream<List<AircraftTypeRow>> watchAircraftTypes(String query) {
    final request = _db.select(_db.aircraftTypes)
      ..orderBy([
        (table) => OrderingTerm.asc(table.family),
        (table) => OrderingTerm.asc(table.code),
      ]);

    final normalizedQuery = normalizeLooseSearch(query);

    return request.watch().map(
          (rows) {
            final mapped = rows.map(AircraftTypeRow.new);
            if (normalizedQuery.isEmpty) {
              return mapped.toList();
            }
            return mapped.where((row) {
              final code = normalizeLooseSearch(row.type.code);
              final family = normalizeLooseSearch(row.type.family);
              final longName = normalizeLooseSearch(row.type.longName);
              final manufacturer = normalizeLooseSearch(
                row.type.manufacturer ?? '',
              );
              return code.contains(normalizedQuery) ||
                  family.contains(normalizedQuery) ||
                  longName.contains(normalizedQuery) ||
                  manufacturer.contains(normalizedQuery);
            }).toList();
          },
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
