import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';

class AircraftRepository {
  AircraftRepository(this._db);

  final AppDatabase _db;

  Stream<List<AircraftRow>> watchAircraft(String query) {
    final request = _db.select(_db.aircrafts).join([
      leftOuterJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.aircrafts.aircraftTypeId),
      ),
    ])
      ..orderBy([
        OrderingTerm.desc(_db.aircrafts.isFavorite),
        OrderingTerm.asc(_db.aircrafts.registration),
      ]);

    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      final term = '%$trimmed%';
      request.where(_db.aircrafts.registration.like(term));
    }

    return request.watch().map((rows) {
      return rows.map((row) {
        final aircraft = row.readTable(_db.aircrafts);
        final type = row.readTableOrNull(_db.aircraftTypes);
        return AircraftRow(aircraft, type);
      }).toList();
    });
  }

  Future<void> toggleLock(Aircraft item) async {
    await _db.update(_db.aircrafts).replace(
          item.copyWith(isLocked: !item.isLocked),
        );
  }

  Future<void> toggleFavorite(Aircraft item) async {
    await _db.update(_db.aircrafts).replace(
          item.copyWith(isFavorite: !item.isFavorite),
        );
  }

  Future<void> delete(Aircraft item) async {
    await _db.delete(_db.aircrafts).delete(item);
  }

  Future<int> create(AircraftsCompanion companion) {
    return _db.into(_db.aircrafts).insert(companion);
  }

  Future<void> update(Aircraft item) async {
    await _db.update(_db.aircrafts).replace(item);
  }

  Future<int> countDuplicateRegistration(
    String registration,
    int currentId,
  ) async {
    final countExpr = _db.aircrafts.id.count();
    final query = _db.selectOnly(_db.aircrafts)
      ..addColumns([countExpr])
      ..where(
        _db.aircrafts.registration.lower().equals(registration.toLowerCase()) &
            _db.aircrafts.id.isNotIn([currentId]),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
