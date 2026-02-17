import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/state/providers/airport_repository_provider.dart';
import 'package:simplelog/state/providers/database_provider.dart';

import 'data_controller.dart';
import 'validation_result.dart';

class AirportDataController extends Notifier<void>
    implements DataController<Airport, AirportsCompanion> {
  @override
  void build() {}

  @override
  Future<ValidationResult> validateCreate(
    AirportsCompanion companion,
  ) async {
    final icao = companion.icao.value.trim();
    if (icao.isEmpty) {
      return ValidationResult.error('ICAO code is required.');
    }
    if (icao.length != 4) {
      return ValidationResult.error('ICAO code must be 4 characters.');
    }
    final repo = ref.read(airportRepositoryProvider);
    final duplicate = await repo.countDuplicateIcao(icao, -1);
    if (duplicate > 0) {
      return ValidationResult.error('ICAO code already exists.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateUpdate(Airport item) async {
    final icao = item.icao.trim();
    if (icao.isEmpty) {
      return ValidationResult.error('ICAO code is required.');
    }
    if (icao.length != 4) {
      return ValidationResult.error('ICAO code must be 4 characters.');
    }
    final repo = ref.read(airportRepositoryProvider);
    final duplicate = await repo.countDuplicateIcao(icao, item.id);
    if (duplicate > 0) {
      return ValidationResult.error('ICAO code already exists.');
    }
    return ValidationResult.ok();
  }

  @override
  Future<ValidationResult> validateDelete(Airport item) async {
    if (item.isLocked) {
      return ValidationResult.error('This airport is locked.');
    }
    final db = ref.read(databaseProvider);
    final countExpr = db.flights.id.count();
    final flightsQuery = db.selectOnly(db.flights)
      ..addColumns([countExpr])
      ..where(db.flights.departureAirportId.equals(item.id) |
          db.flights.arrivalAirportId.equals(item.id));
    final flightsRow = await flightsQuery.getSingle();
    final flightCount = flightsRow.read(countExpr) ?? 0;

    final posCountExpr = db.positionings.id.count();
    final posQuery = db.selectOnly(db.positionings)
      ..addColumns([posCountExpr])
      ..where(db.positionings.departurePlaceId.equals(item.id) |
          db.positionings.arrivalPlaceId.equals(item.id));
    final posRow = await posQuery.getSingle();
    final posCount = posRow.read(posCountExpr) ?? 0;

    final usedCount = flightCount + posCount;
    if (usedCount > 0) {
      return ValidationResult.error(
        'Cannot delete. Airport used in $usedCount logbook entries.',
      );
    }
    return ValidationResult.ok();
  }

  @override
  Future<int?> create(AirportsCompanion companion) async {
    final repo = ref.read(airportRepositoryProvider);
    return repo.create(companion);
  }

  @override
  Future<void> update(Airport item) async {
    final repo = ref.read(airportRepositoryProvider);
    await repo.update(item);
  }

  @override
  Future<void> delete(Airport item) async {
    final repo = ref.read(airportRepositoryProvider);
    await repo.delete(item);
  }
}
