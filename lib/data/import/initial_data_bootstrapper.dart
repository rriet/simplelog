import 'package:drift/drift.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/import/airport_seed_importer.dart';
import 'package:simplelog/data/import/crew_seed_importer.dart';
import 'package:simplelog/data/import/dashboard_rules_seed_importer.dart';

/// Seeds initial app data only when the whole database is effectively empty.
///
/// This avoids re-creating partial defaults (like `Self` crew) when a user
/// deletes one entity manually.
class InitialDataBootstrapper {
  const InitialDataBootstrapper();

  Future<void> bootstrapIfDatabaseEmpty(AppDatabase db) async {
    final hasAnyData = await _hasAnyData(db);
    if (hasAnyData) {
      return;
    }

    const airportImporter = AirportSeedImporter();
    await airportImporter.importIfEmpty(db);

    const crewImporter = CrewSeedImporter();
    await crewImporter.importIfEmpty(db);

    // If DB is empty, rules should be seeded regardless of stale prefs.
    await DashboardRulesSeedImporter.clearSeedFlag();
    const dashboardRulesImporter = DashboardRulesSeedImporter();
    await dashboardRulesImporter.importOnFirstOpen(db);
  }

  Future<bool> _hasAnyData(AppDatabase db) async {
    final tables = <TableInfo>[
      db.airports,
      db.aircraftTypes,
      db.aircrafts,
      db.crew,
      db.flights,
      db.simulatorTrainings,
      db.positionings,
      db.dutyPeriods,
      db.previousExperiences,
      db.limitRules,
      db.timeLines,
    ];
    for (final table in tables) {
      final count = await _tableCount(db, table);
      if (count > 0) {
        return true;
      }
    }
    return false;
  }

  Future<int> _tableCount(AppDatabase db, TableInfo table) async {
    final countExpr = table.$primaryKey.first.count();
    final query = db.selectOnly(table)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}

