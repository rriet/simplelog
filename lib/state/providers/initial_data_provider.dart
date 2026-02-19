import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/import/airport_seed_importer.dart';
import 'package:simplelog/data/import/crew_seed_importer.dart';
import 'package:simplelog/data/import/dashboard_rules_seed_importer.dart';
import 'package:simplelog/state/providers/database_provider.dart';

final initialDataProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseProvider);
  const importer = AirportSeedImporter();
  await importer.importIfEmpty(db);
  const crewImporter = CrewSeedImporter();
  await crewImporter.importIfEmpty(db);
  const dashboardRulesImporter = DashboardRulesSeedImporter();
  await dashboardRulesImporter.importOnFirstOpen(db);
});
