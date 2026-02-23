import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/import/initial_data_bootstrapper.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Bootstraps initial seed data when the database is empty.
final initialDataProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseProvider);
  const bootstrapper = InitialDataBootstrapper();
  await bootstrapper.bootstrapIfDatabaseEmpty(db);
});
