// ignore_for_file: annotate_overrides

import 'package:drift/drift.dart';
import 'package:simplelog/core/text/search_normalizer.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/domain/repositories/aircraft_repository_contract.dart';

class AircraftRepository implements AircraftRepositoryContract {
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

    final normalizedQuery = normalizeLooseSearch(query);

    return request.watch().map((rows) {
      final mapped = rows.map((row) {
        final aircraft = row.readTable(_db.aircrafts);
        final type = row.readTableOrNull(_db.aircraftTypes);
        return AircraftRow(aircraft, type);
      });
      if (normalizedQuery.isEmpty) {
        return mapped.toList();
      }
      return mapped.where((row) {
        final registration = normalizeLooseSearch(row.aircraft.registration);
        return registration.contains(normalizedQuery);
      }).toList();
    });
  }

  Future<List<AircraftRow>> fetchAircraftByType(int aircraftTypeId) async {
    final query = _db.select(_db.aircrafts).join([
      leftOuterJoin(
        _db.aircraftTypes,
        _db.aircraftTypes.id.equalsExp(_db.aircrafts.aircraftTypeId),
      ),
    ])
      ..where(_db.aircrafts.aircraftTypeId.equals(aircraftTypeId))
      ..orderBy([
        OrderingTerm.desc(_db.aircrafts.isFavorite),
        OrderingTerm.asc(_db.aircrafts.registration),
      ]);

    final rows = await query.get();
    return rows
        .map(
          (row) => AircraftRow(
            row.readTable(_db.aircrafts),
            row.readTableOrNull(_db.aircraftTypes),
          ),
        )
        .toList();
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

  @override
  Future<int> countFlightsForAircraft(int aircraftId) async {
    final countExpr = _db.flights.id.count();
    final query = _db.selectOnly(_db.flights)
      ..addColumns([countExpr])
      ..where(_db.flights.aircraftId.equals(aircraftId));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  @override
  Future<int> countSimSessionsForAircraft(int aircraftId) async {
    final countExpr = _db.simulatorTrainings.id.count();
    final query = _db.selectOnly(_db.simulatorTrainings)
      ..addColumns([countExpr])
      ..where(_db.simulatorTrainings.aircraftId.equals(aircraftId));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
