import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/import/airport_seed_importer.dart';
import 'package:simplelog/state/providers/database_provider.dart';

final initialDataProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseProvider);
  const importer = AirportSeedImporter();
  await importer.importIfEmpty(db);
});
