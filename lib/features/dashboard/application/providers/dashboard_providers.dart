import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/repositories/dashboard_repository.dart';
import 'package:simplelog/features/dashboard/domain/dashboard_models.dart';
import 'package:simplelog/state/providers/database_provider.dart';

/// Public API documentation.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DashboardRepository(db);
});
/// Public API documentation.

/// Public API documentation.
final dashboardRulesProvider = StreamProvider<List<LimitRule>>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchRules();
/// Public API documentation.
});

/// Public API documentation.
final dashboardCardsProvider = StreamProvider<List<DashboardRuleCard>>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchDashboardCards();
});
