import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/repositories/reports_repository.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Provides the reports repository backed by the current database instance.
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ReportsRepository(db);
});
